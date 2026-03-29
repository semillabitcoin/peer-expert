# Worked Examples

> **ALL NUMBERS BELOW ARE FICTIONAL EXAMPLES.** The rates, spreads, fees, and amounts shown here are for illustrating the PROCESS only. Never use these numbers in a real response. Always query the indexer for current data.

## Scenario A: "Quiero comprar $200 en BTC con Revolut desde EUR"

**Step 1 — Parse the request:**
- Amount: EUR200
- Payment method: Revolut
- Currency: EUR
- Destination: BTC
- Chain: not specified -> recommend Base (cheapest), then swap to BTC

**Step 2 — Query live rates for EUR via Revolut:**

```bash
curl -sL -X POST "https://indexer.zkp2p.xyz/v1/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ Deposit(limit: 20, where: {acceptingIntents: {_eq: true}, status: {_eq: \"ACTIVE\"}, remainingDeposits: {_gt: \"1000000\"}}, order_by: {remainingDeposits: desc}) { depositId remainingDeposits currencies(where: {currencyCode: {_eq: \"0xfff16d60be267153303bbfa66e593fb8d06e24ea5ef24b6acca5224c2ca6b907\"}}) { takerConversionRate spreadBps paymentMethodHash rateSource } } }"}'
```

**Step 3 — Filter results for Revolut hash** (`0x617f88...`):

Suppose the query returns a deposit with:
- `takerConversionRate`: `952000000000000000` -> 0.952 (means 0.952 EUR per 1 USDC)
- `spreadBps`: `150` -> 1.5%
- `remainingDeposits`: `15000000000` -> $15,000 available

**Step 4 — Calculate total cost:**

```
Spread:        1.5%
Manager fee:  0.1%
Bridge fee:    0% (staying on Base for USDC, swap to BTC adds ~0.3%)
BTC swap fee:  ~0.3% (DEX slippage)
Total cost:    ~1.9%
```

**Step 5 — Calculate what the user gets:**

```
Sending:       EUR200
Rate:          0.952 EUR/USDC -> EUR200 / 0.952 = ~210.08 USDC
Manager fee:  -0.21 USDC (0.1%)
USDC received: ~209.87 USDC on Base
After BTC swap: ~209.24 USDC worth of BTC (~0.3% swap fee)
Total fees:    ~EUR3.76 (~1.9% of EUR200)
```

**Step 6 — Present to user:**

> Para comprar BTC con EUR200 via Revolut:
>
> - **Spread**: 1.5% - **Total cost**: ~1.9% (~EUR3.76)
> - **Recibirias**: ~$209.24 en BTC en Base
> - **Liquidez disponible**: $15,000
>
> Quieres que te guie paso a paso?

**Important notes:**
- The rate 0.952 EUR/USDC means EUR is worth more than USD (you pay less EUR per USDC)
- Always double-check: does the user want EUR200 worth or $200 worth? Ask if ambiguous
- BTC swap adds a small fee — mention it upfront
- For BTC on Bitcoin mainnet: use Relay API for exact fees (see bridge-fees.md)

---

## Scenario B: "Quiero comprar USDC con $500 usando Zelle"

> FICTIONAL NUMBERS — always query live data.

**Parse:** $500 USD, Zelle, USDC on Base (no bridge needed).

**Key differences from EUR example:**
- USD rate is close to 1:1 (e.g., `takerConversionRate`: `1015000000000000000` -> 1.015 USD/USDC)
- Zelle is medium-risk (1.5x cap multiplier) — check user's tier can handle $500
- Cooldown applies for Peasant/Peer tiers on Zelle
- Zelle has 3 variants (Citi/Chase/BofA) — filter by the correct hash

**Cost breakdown:**
```
Sending:       $500
Rate:          1.015 USD/USDC -> $500 / 1.015 = ~492.61 USDC
Manager fee:  -0.49 USDC (0.1%)
USDC received: ~492.12 USDC on Base
Total fees:    ~$7.88 (~1.58%)
```

**Tier check:** $500 via Zelle requires at least Peer Plus ($1,500 cap at 1.5x).

---

## Scenario C: "Quiero comprar crypto con 50,000 ARS usando MercadoPago"

> FICTIONAL NUMBERS — always query live data.

**Parse:** 50,000 ARS, MercadoPago, destination not specified -> ask user.

**Key differences:**
- ARS is highly volatile — rate changes fast (e.g., `takerConversionRate`: `1250000000000000000000` -> 1,250 ARS/USDC)
- MercadoPago is low-risk (5x cap multiplier) — generous limits
- Spreads tend to be higher for ARS (2-5% typical)

**Cost breakdown:**
```
Sending:       50,000 ARS
Rate:          1,250 ARS/USDC -> 50,000 / 1,250 = ~40.00 USDC
Manager fee:  -0.04 USDC (0.1%)
USDC received: ~39.96 USDC on Base
Spread:        ~3% -> total fees ~3.1% -> ~1,550 ARS
```

**Important ARS notes:**
- Always present the USDC equivalent so the user understands the dollar value
- ARS rates can have 18+ digits raw — be careful with decimal conversion
- MercadoPago requires CVU as payee detail, not email/username
- No cooldown on MercadoPago (low-risk platform)

---

## Scenario D: "I want to buy ETH with GBP300 using Monzo"

> FICTIONAL NUMBERS — always query live data.

**Parse:** GBP300, Monzo, ETH (needs chain — ask: Ethereum mainnet or Base?).

**Key differences:**
- GBP is worth more than USD — rate < 1 (e.g., 0.79 GBP/USDC)
- Monzo is GBP-only, low-risk (5x cap)
- ETH requires bridge fee — **must query Relay API** for exact cost
- Need to specify destination chain for ETH (Ethereum mainnet, Arbitrum, Base)

**Cost breakdown (ETH on Ethereum mainnet):**
```
Sending:       GBP300
Rate:          0.79 GBP/USDC -> GBP300 / 0.79 = ~379.75 USDC
Manager fee:  -0.38 USDC (0.1%)
Bridge fee:    -1.52 USDC (0.4% via Relay to Ethereum)
USDC after:    ~377.85 -> swapped to ETH at market rate
Total fees:    ~GBP5.70 (~1.9%)
```

**Always run the Relay quote** for non-Base destinations — don't estimate bridge fees.

---

## Scenario E: "Quiero proveer liquidez con $5,000 USDC en Revolut para EUR" (SELLING)

> FICTIONAL NUMBERS — always query live data.

**Step 1 — Parse the request:**
- Role: Seller (liquidity provider)
- Amount: 5,000 USDC
- Payment method: Revolut
- Currency: EUR
- Goal: Earn yield passively

**Step 2 — Check current EUR/Revolut market:**

Query the order book for EUR to see what spreads competitors are offering:

```bash
curl -sL -X POST "https://indexer.zkp2p.xyz/v1/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ Deposit(limit: 100, where: {acceptingIntents: {_eq: true}, status: {_eq: \"ACTIVE\"}, remainingDeposits: {_gt: \"0\"}}, order_by: {remainingDeposits: desc}) { depositId remainingDeposits intentAmountMin intentAmountMax rateManagerId currencies(where: {currencyCode: {_eq: \"0xfff16d60be267153303bbfa66e593fb8d06e24ea5ef24b6acca5224c2ca6b907\"}}) { takerConversionRate conversionRate spreadBps paymentMethodHash rateSource } } }"}'
```

**Step 3 — Analyze the competition:**

Suppose the order book shows EUR/Revolut deposits at these spreads:
- 3 deposits at +0.06% to +0.10% (tight, high volume)
- 2 deposits at +0.50% to +0.66% (moderate)
- 1 deposit at +1.50% (wide, slow fills)

**Step 4 — Recommend a spread:**

```
Strategy options:

1. Aggressive (+0.10%): Match the tightest spread
   - Fast fills, low margin
   - APR estimate: ~3.6% (if 10-day cycle)

2. Balanced (+0.60%): Sit in the middle
   - Moderate fills, decent margin
   - APR estimate: ~21.9% (if 10-day cycle)

3. Wide (+1.50%): Above most competition
   - Slow fills, high margin per trade
   - APR estimate: ~54.8% (if 10-day cycle)

Recommendation: Start at +0.60% and adjust based on fill rate.
If filling instantly -> raise spread. If idle for days -> lower it.
```

**Step 5 — Calculate expected APR:**

```
APR = (spread x 365 / daysPerCycle) x 100%

At +0.60% spread, 10-day cycle:
APR = (0.006 x 365 / 10) x 100% = ~21.9%

On $5,000 deposit: ~$1,095/year or ~$91/month in fiat payments
```

**Step 6 — Guide the deposit setup:**

```
1. Go to peer.xyz -> "Sell" tab
2. Connect wallet with 5,000 USDC on Base
3. Click "New Deposit" -> enter 5,000 USDC
4. Select Revolut -> enter your Revtag
5. Set spread to +0.60% (ARM handles rate automatically)
6. (Optional) Add more currencies: GBP, USD, CHF
7. (Optional) Set floor rate: 0.92 EUR/USDC (protection against drops)
8. (Optional) Set min order: 5 USDC, max order: 2,500 USDC
9. Click Approve -> confirm transaction
```

**Step 7 — Present to user:**

> Para proveer liquidez con $5,000 USDC via Revolut (EUR):
>
> - **Spread recomendado**: +0.60% (competitivo, buen balance)
> - **APR estimado**: ~22% (~$91/mes)
> - **Competencia**: 6 depositos activos, spreads de 0.06% a 1.50%
> - **Tu posicion**: ranking 4 de 7 por precio
>
> Quieres que te guie paso a paso para configurarlo?

**Important notes:**
- APR depends on trade volume — if nobody trades EUR/Revolut, yield is zero
- Seller must rebalance: convert received EUR back to USDC periodically
- ARM auto-adjusts the rate from oracle — the spread stays fixed
- Multiple currencies on one deposit = more potential buyers
- Check arm.peer.xyz for oracle health if fills suddenly stop
