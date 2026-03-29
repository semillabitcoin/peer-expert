# Peer Indexer — Real-Time Query Reference

## Endpoint

**Primary** (more complete data — includes all active currencies and payment methods):
```
POST https://indexer.zkp2p.xyz/v1/graphql
Content-Type: application/json
```

**Fallback** (if primary is down):
```
POST https://indexer.hyperindex.xyz/8fd74dc/v1/graphql
Content-Type: application/json
```

No authentication required. Both are public GraphQL endpoints with the same schema. Use the primary endpoint by default — it consistently shows more active deposits and currencies.

## Hash Tables

Payment method hashes and currency code hashes are in **SKILL.md** (always loaded in context). Use those for decoding query results. Additional currencies without active liquidity: BRL, NGN (ARM oracle feeds exist at arm.peer.xyz but no deposits yet).

## Decoding Rates

Rates are stored as uint256 with 18 decimals. To convert:

```
humanRate = rawRate / 1e18
```

The rate means: how much FIAT you pay per 1 USDC.

- `takerConversionRate`: what the buyer actually pays (includes spread)
- `conversionRate`: the base rate set by the seller
- `spreadBps`: spread in basis points (100 bps = 1%)

## Key Queries

### 1. Best rates for a specific currency

Replace `CURRENCY_HASH` with the hash from the table above.

```graphql
{
  Deposit(
    limit: 20
    where: {
      acceptingIntents: { _eq: true }
      status: { _eq: "ACTIVE" }
      remainingDeposits: { _gt: "1000000" }
    }
    order_by: { remainingDeposits: desc }
  ) {
    depositId
    remainingDeposits
    currencies(where: { currencyCode: { _eq: "CURRENCY_HASH" } }) {
      conversionRate
      takerConversionRate
      spreadBps
      paymentMethodHash
      rateSource
    }
  }
}
```

### 2. All rates for a specific deposit

```graphql
{
  Deposit(where: { depositId: { _eq: "DEPOSIT_ID" } }) {
    depositId
    remainingDeposits
    acceptingIntents
    rateManagerId
    currencies {
      currencyCode
      conversionRate
      takerConversionRate
      spreadBps
      paymentMethodHash
      rateSource
      minConversionRate
    }
    paymentMethods {
      paymentMethodHash
      active
    }
  }
}
```

### 2b. Determine manager fee for a deposit (real-time)

**Primary method**: read `rateManagerId` directly from the Deposit (updates in real-time in the indexer):

```graphql
{
  Deposit(
    where: { depositId: { _eq: "DEPOSIT_ID" } }
    order_by: { updatedAt: desc }
    limit: 1
  ) {
    depositId
    rateManagerId
    rateManagerAddress
    updatedAt
  }
}
```

Then look up the fee using this table (verified across 500+ trades, zero exceptions):

| `rateManagerId` | Fee |
|---|---|
| `null` | **0%** — always, no exceptions |
| `0x65b1056ef2dbdcd3b5f9ac170bb89eb2718b3a7a09d7eb0160d15623cfeefc6e` | **0.100%** |
| `0x8666d6fb0f6797c56e95339fd7ca82fdd348b9db200e10a4c4aa0a0b879fc41c` | **0.100%** |
| `0xd99ad8f04bc1118c176e77bfd8a53ac156edcabdff2cb329a209155c712800ec` | **0.095%** |

Each `rateManagerId` identifies an ARM config contract — the fee is baked into that config and stays consistent. A seller can migrate their deposit to a different ARM (changing the `rateManagerId`), but the mapping from ID→fee is stable.

**Important**: Deposits can have multiple rows in the indexer (versioned). Always use `order_by: { updatedAt: desc }, limit: 1` to get the current state. Deposit 144 migrated from null→ARM on 2026-03-28, and the indexer reflected this in real-time.

**Fallback for unknown `rateManagerId`**: query the most recent fulfilled intent:

```graphql
{
  Intent(
    limit: 1
    where: {
      depositId: { _eq: "FULL_DEPOSIT_ID" }
      status: { _eq: "FULFILLED" }
    }
    order_by: { fulfillTimestamp: desc }
  ) {
    managerFee
    managerFeeAmount
    managerFeeRecipient
    rateManagerId
  }
}
```

Add any new `rateManagerId`→fee mapping you discover to the lookup table above.

Fee values (18-decimal format):
- `0` or `null` → 0% fee
- `950000000000000` → 0.095%
- `1000000000000000` → 0.1%

### 3. All active rates across all currencies (market overview)

```graphql
{
  Deposit(
    limit: 15
    where: {
      acceptingIntents: { _eq: true }
      status: { _eq: "ACTIVE" }
      remainingDeposits: { _gt: "5000000" }
    }
    order_by: { remainingDeposits: desc }
  ) {
    depositId
    remainingDeposits
    currencies {
      currencyCode
      takerConversionRate
      spreadBps
      paymentMethodHash
      rateSource
    }
  }
}
```

### 4. Liquidity order book (replicates peer.xyz/liquidity)

Returns all active deposits with their spreads, amounts, and payment methods — same data as the Liquidity page. Filter by currency hash to get one currency's order book.

```graphql
{
  Deposit(
    limit: 100
    where: {
      acceptingIntents: { _eq: true }
      status: { _eq: "ACTIVE" }
      remainingDeposits: { _gt: "0" }
    }
    order_by: { remainingDeposits: desc }
  ) {
    depositId
    remainingDeposits
    intentAmountMin
    intentAmountMax
    rateManagerId
    currencies(where: { currencyCode: { _eq: "CURRENCY_HASH" } }) {
      currencyCode
      takerConversionRate
      conversionRate
      spreadBps
      paymentMethodHash
      rateSource
    }
  }
}
```

Remove the `currencies(where: ...)` filter to get all currencies at once.

### Multi-escrow deposits

A single `depositId` can appear **multiple times** in results, each with different `remainingDeposits`, `intentAmountMin/Max`, and `currencies`. This happens because one maker can have multiple escrow positions (sub-deposits) under the same ID, each configured with different payment methods, amount ranges, and spreads.

When presenting results:
- Group by `depositId` but show each sub-deposit as a separate row if they have different methods/ranges
- Show the `intentAmountMin`--`intentAmountMax` range so the user knows the order size limits per position
- The web at peer.xyz shows this as different payment methods with specific max amounts per method

Presentation (replicate peer.xyz/liquidity):

**Derive oracle reference rate first:**
From all entries with `rateSource: ORACLE` and `spreadBps` not null:
`oracleRef = conversionRate / (1 + spreadBps / 10000)`
All ORACLE entries should give the same value. Use the median.

The Chainlink feed is also available: `ChainlinkAggregatorV3_AnswerUpdated(limit:1, where:{feed:{_eq:"EUR_FEED_ADDRESS"}}, order_by:{updatedAt:desc}) { current }` — divide by 1e8 for EUR/USD, then `1 / eurUsd` for EUR/USDC.

**Filtering:**
- Skip `currencies: []`, `rateSource: NO_FLOOR`, `takerConversionRate: 0`
- Skip `ESCROW_FLOOR` where `takerConversionRate / 1e18 < oracleRef` (stale below-market rates)

**Spread calculation:**
`effectiveSpread = (takerConversionRate / 1e18 / oracleRef - 1) * 100`
Do NOT use `spreadBps` directly — it is the maker's configured value, not the effective spread vs current oracle.

**Grouping and sorting:**
- Group entries within 0.0001 of same `takerConversionRate / 1e18`
- Sum amounts, combine provider names, show deposit count as (N)
- Sort by price ascending (cheapest first)

**Columns:** Price | (N) | Spread | Amount | Total (cumulative) | Providers
- Amount = `remainingDeposits / 1e6` (USDC)
- Total = running sum of Amount
- APR = requires per-deposit fill rate data (web backend); show "-"

Decoding notes:
- `spreadBps` is an integer (basis points) — the exact value the maker configured. 1 bps = 0.01% resolution. Can be `null` for `MANAGER` or `NO_FLOOR` entries
- `conversionRate` is the base rate before spread — useful for calculating real spread vs oracle
- `rateSource` values:
  - `ORACLE` — rate auto-updates from market oracle + spread. Most reliable
  - `MANAGER` — vault/strategy managed. Reliable, may adjust dynamically
  - `ESCROW_FLOOR` — fixed rate set manually by maker. May be stale
  - `NO_FLOOR` — no minimum rate. Usually has null spread and zero rate — skip these
- Skip entries with `rateSource: NO_FLOOR` or `takerConversionRate: 0`
- Flag `ESCROW_FLOOR` deposits whose spread looks off vs `ORACLE` deposits — maker may have forgotten to update

### 5. Total platform liquidity

Note: `Deposit_aggregate` is NOT available on this indexer. Sum deposits manually:

```graphql
{
  Deposit(
    limit: 200
    where: {
      acceptingIntents: { _eq: true }
      status: { _eq: "ACTIVE" }
      remainingDeposits: { _gt: "0" }
    }
  ) {
    remainingDeposits
  }
}
```

Sum all `remainingDeposits` values (divide each by 1e6) to get total liquidity. Count the array length for number of active deposits.

### 6. Recent fulfilled intents (volume indicator)

Note: `Intent` has no `deposit` relation field. Use `depositId` (string) directly.

```graphql
{
  Intent(
    limit: 20
    where: { status: { _eq: "FULFILLED" } }
    order_by: { fulfillTimestamp: desc }
  ) {
    amount
    depositId
    fiatCurrency
    paymentMethodHash
    fulfillTimestamp
    conversionRate
    releasedAmount
    takerAmountNetFees
  }
}
```

Available Intent fields: `amount`, `conversionRate`, `depositId`, `expiryTime`, `fiatCurrency`, `fulfillTimestamp`, `fulfillTxHash`, `id`, `intentHash`, `isExpired`, `managerFee`, `managerFeeAmount`, `owner`, `paymentAmount`, `paymentCurrency`, `paymentMethodHash`, `paymentTimestamp`, `releasedAmount`, `signalTimestamp`, `signalTxHash`, `status`, `takerAmountNetFees`, `toAddress`, `updatedAt`, `verifier`.

### 8. Tier lookup by wallet address

Query all fulfilled intents for a wallet to calculate their total volume and determine their tier:

```graphql
{
  Intent(
    where: {
      status: { _eq: "FULFILLED" }
      owner: { _eq: "WALLET_ADDRESS" }
    }
  ) {
    amount
    fulfillTimestamp
  }
}
```

Sum all `amount / 1e6` values for total fulfilled volume in USD. Map to tier:

| Volume | Tier | Base Cap |
|--------|------|----------|
| $0 | Peer Peasant | $100 |
| $500+ | Peer | $250 |
| $2,000+ | Peer Plus | $1,000 |
| $10,000+ | Peer Pro | $2,500 |
| $25,000+ | Peer Platinum | $5,000 |

Multiply base cap by platform multiplier (5x for Revolut/Wise/Monzo/MercadoPago, 1.5x for Zelle, 1x for Venmo/CashApp, 0.75x for PayPal) for effective cap.

## curl Template

```bash
curl -sL -X POST "https://indexer.zkp2p.xyz/v1/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query": "YOUR_QUERY_HERE"}'
```

## Quote API (alternative)

The SDK also exposes a Quote API at `https://api.zkp2p.xyz/v2/quote/exact-fiat` (POST, JSON body). This is used by the frontend to find best matches. It requires specific fields:

```json
{
  "paymentPlatforms": ["wise", "revolut"],
  "fiatCurrency": "USD",
  "exactFiatAmount": "100",
  "user": "0xTAKER_ADDRESS",
  "recipient": "0xRECIPIENT_ADDRESS",
  "destinationChainId": 8453,
  "destinationToken": "0x833589fcd6edb6e08f4c7c32d4f71b54bda02913"
}
```

Note: The Quote API may require a valid taker address. For general rate comparison, use the indexer GraphQL queries instead.

## USDC Contract (Base)

```
0x833589fcd6edb6e08f4c7c32d4f71b54bda02913
```

Chain IDs are in `bridge-fees.md`.

## 7. Discovery query (detect new hashes)

Peer may add new payment methods or currencies at any time. Run this query to detect hashes not in SKILL.md:

```graphql
{
  Deposit(
    limit: 50
    where: {
      acceptingIntents: { _eq: true }
      status: { _eq: "ACTIVE" }
      remainingDeposits: { _gt: "1000000" }
    }
  ) {
    currencies {
      currencyCode
      paymentMethodHash
    }
  }
}
```

Compare every `paymentMethodHash` and `currencyCode` in the response against the known hashes in SKILL.md. Any hash not in the list is a new addition to the platform — flag it to the user and still show its rate/liquidity data.

## Staying Updated

The data in this skill (payment methods, currencies, chains, tiers, fees) is a snapshot and WILL lag behind the live platform. When accuracy matters:

1. **Rates and liquidity**: ALWAYS query the indexer live — never rely on examples
2. **Payment methods and currencies**: Run the discovery query (above) to detect new hashes
3. **Chains**: Check https://peer.xyz for the latest supported chains
4. **Tiers/fees**: Check https://docs.peer.xyz/guides/for-buyers/reputation for current tier rules
5. **SDK**: Check https://docs.peer.xyz/developer/sdk — method names change between versions

If the user reports something that doesn't match this skill's knowledge:
- Check https://docs.peer.xyz for updated guides
- Query the indexer to verify current state
- Check https://github.com/zkp2p for protocol updates
- The Peer team announces changes on https://x.com/peerxyz and Telegram https://t.me/+XDj9FNnW-xs5ODNl
