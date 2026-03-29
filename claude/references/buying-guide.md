# Buying Guide — Step-by-Step + Tiers + Decision Helper

## PAYMENT METHOD RISK LEVELS

> **Static reference** — for risk levels and cap multipliers only. To see which methods currently have liquidity and at what spreads, query the indexer.

| Platform | Currencies | Risk Level | Cap Multiplier | Notes |
|----------|-----------|------------|----------------|-------|
| Revolut | Multi (EUR, GBP, USD, etc.) | Low | 5x | Best for non-USD. No chargebacks |
| Wise | Multi (EUR, GBP, USD, etc.) | Low | 5x | Good international coverage |
| Monzo | GBP only | Low | 5x | UK only |
| MercadoPago | ARS only | Low | 5x | Argentina/LATAM |
| Zelle | USD only (Citi, Chase, BofA) | Medium | 1.5x | US bank-to-bank |
| Venmo | USD only | High | 1x | ACH-backed, 90-day reversal window |
| CashApp | USD only | High | 1x | ACH-backed, 90-day reversal window |
| PayPal | Multi | Highest | 0.75x | 180-day buyer protection. Requires Peer Plus tier |
| Chime | USD only | Medium | -- | US neobank. Liquidity varies |
| Luxon | Multi | -- | -- | Newer addition. Check indexer for current liquidity |
| N26 | EUR | -- | -- | European neobank |
| Alipay | CNY | -- | -- | Chinese market |

---

## TAKER TIERS (Reputation System)

Peer has an on-chain reputation system that determines order limits and cooldowns.

### Tier Levels

| Tier | Volume Threshold | Base Cap | Cooldown |
|------|-----------------|----------|----------|
| Peer Peasant | $0 | $100 | 12 hours |
| Peer | $500 | $250 | 6 hours |
| Peer Plus | $2,000 | $1,000 | No cooldown |
| Peer Pro | $10,000 | $2,500 | No cooldown |
| Peer Platinum | $25,000 | $5,000 | No cooldown |

### Effective Caps (Base Cap x Platform Multiplier)

| Tier | Revolut/Wise/Monzo/MercadoPago (5x) | Zelle (1.5x) | Venmo/CashApp (1x) | PayPal (0.75x) |
|------|--------------------------------------|--------------|---------------------|----------------|
| Peasant ($100 base) | **$500** | $150 | $100 | Locked |
| Peer ($250 base) | **$1,250** | $375 | $250 | Locked |
| Peer Plus ($1,000 base) | **$5,000** | $1,500 | $1,000 | $750 |
| Peer Pro ($2,500 base) | **$12,500** | $3,750 | $2,500 | $1,875 |
| Peer Platinum ($5,000 base) | **$25,000** | $7,500 | $5,000 | $3,750 |

Volume is measured as **Total Fulfilled Volume** — the cumulative USD value of all orders successfully completed (onchain).

### Cooldown Rules

- Low-risk platforms (Revolut, Wise, Monzo, MercadoPago): **NO cooldown** regardless of tier
- Medium/high-risk (Zelle, Venmo, CashApp, PayPal): Cooldown applies for Peasant and Peer tiers
- Cooldown is per-user, not per-platform
- Peer Plus and above: No cooldown on any platform

### Lock Score (Penalties)

- Cancelling orders after 15 minutes increases lock score
- Cancelling within 15 minutes: no penalty
- Completing orders dilutes lock score over time

| Lock Score | Penalty |
|-----------|---------|
| 50+ | -1 tier |
| 200+ | -2 tiers |
| 500+ | -3 tiers |
| 1000+ | -4 tiers |

### Tier Benefits

- Peer Plus+: Access to PayPal, no cooldowns, higher caps
- Peer Platinum: Private Discord, early mobile app access, max caps

### Advice for New Users

- Start with low-risk platforms (Revolut, Wise) — 5x cap multiplier and no cooldown
- Complete orders reliably to build volume fast
- Never cancel after 15 minutes — it penalizes your score
- Use Revolut to reach Peer Plus ($2,000) fastest, then unlock PayPal if needed

---

## BUYING FLOW (Step-by-Step)

When guiding a user to buy, follow this flow. Send ONE step at a time and wait for confirmation.

### Step 1: Gather Requirements

Ask:
- What payment method? (or let them choose after seeing rates)
- How much in their local currency?
- What crypto? (USDC, ETH, BTC, SOL, etc.)
- What chain? (if they don't know, recommend Base for lowest fees)
- Do they have a wallet or prefer social login?

### Step 2: Query Live Rates

Query the indexer for their currency. Present the top 3 options ranked by total cost. Include:
- Payment method name
- Spread %
- Total cost % (spread + manager fee + bridge if applicable)
- Available liquidity
- Fee in their currency for their amount

### Step 3: Connect to Peer

```
1. Open https://peer.xyz in Chrome
2. Click wallet icon (top-right)
3. Connect wallet (MetaMask, Rabby) OR sign in with Google/Email/Twitter
   -> Social login = no gas fees, no wallet needed
```

### Step 4: Configure Purchase

```
1. Click "Buy" tab
2. Currency: [their currency]
3. Amount: [their amount]
4. Payment method: [recommended method]
5. Chain: [chosen chain]
6. Token: [chosen token]
7. Review the rate shown -- confirm it matches what we quoted
```

### Step 5: Start Order

```
1. Click "Start Order"
2. Sign transaction (automatic if using social login)
3. You'll see payment instructions with the recipient details
```

### Step 6: PeerAuth Extension (first time only)

```
FIRST TIME ONLY -- Install PeerAuth Chrome extension:
- Click "Add to Chrome" when prompted
- Or search "PeerAuth" in Chrome Web Store
- It's open source and processes everything locally
- Your private data is NEVER shared
```

### Step 7: Send Payment

```
IMPORTANT:
1. Open [PAYMENT APP]
2. Send EXACTLY [AMOUNT] [CURRENCY] to the recipient shown
3. DO NOT convert currencies inside the payment app
   (e.g., don't send EUR from a USD Revolut account)
4. Once sent, click "I have completed payment" on Peer
```

### Step 8: Verify Payment

```
1. Peer redirects you to [PAYMENT APP] login
2. Log in normally
3. PeerAuth reads the payment data (locally, nothing is shared)
4. Select the correct payment if you have multiple recent ones
5. Click "Verify Payment"
6. Wait ~30 seconds for ZK proof generation
```

### Step 9: Receive Crypto

```
1. Click "Complete Order"
2. Sign transaction (automatic with social login)
3. Crypto arrives in your wallet!
4. Bridge to other chains takes 1-2 extra minutes
```

---

## DECISION HELPER

### Best Payment Method by Scenario

| Scenario | Recommendation | Why |
|----------|---------------|-----|
| Lowest fees | Query live rates, sort by spread | Varies by market |
| Fastest | Revolut or Wise | Low-risk = no cooldown, instant settlement |
| Highest cap | Revolut or Wise | 5x multiplier on any tier |
| New user, wants to build tier fast | Revolut | 5x cap, no cooldown, multi-currency |
| US user, small amounts | Venmo | Most common US P2P app |
| US user, wants higher caps | Zelle | 1.5x multiplier (better than Venmo 1x) |
| Argentina | MercadoPago | Only option for ARS, low-risk 5x cap |
| UK user | Monzo or Revolut | Both low-risk with GBP support |
| Wants PayPal | Must have Peer Plus ($2,000 volume first) | Highest risk, lowest cap (0.75x) |

### Best Chain by Scenario

| Scenario | Chain | Why |
|----------|-------|-----|
| Lowest total cost | Base | Native, no bridge fee |
| Want BTC nativo | Bitcoin (8253038) | BTC real via Relay |
| DeFi on Ethereum | Ethereum | Query Relay for exact fee |
| Trading on Hyperliquid | Hyperliquid | Query Relay for exact fee |
| Solana ecosystem | Solana | Query Relay for exact fee |
| Don't know | Base | Cheapest and fastest |

---

## COMMON QUESTIONS

**Q: Is it really no KYC?**
A: Yes. You connect a wallet (or social login) and use your existing payment apps. No identity documents, no selfies, no waiting for approval.

**Q: Is it safe?**
A: USDC is held in audited smart contracts (escrow). Payments are verified with ZK proofs. Your data stays local. Main risk is payment reversals on high-risk platforms (Venmo, PayPal).

**Q: How long does it take?**
A: 2-5 minutes after sending payment. Includes proof generation (~30s), verification, and on-chain release. Bridge adds 1-2 minutes.

**Q: What are the limits?**
A: New users: $100 per order. Goes up to $5,000+ as you complete more orders. Low-risk platforms (Revolut, Wise) get 5x the base cap.

**Q: Can I buy Bitcoin?**
A: Yes. Peer gives you USDC which is automatically bridged and swapped to BTC (or any token) on your chosen chain.

**Q: What if something goes wrong?**
A: Your money is in on-chain escrow. If auto-verification fails, the seller can release manually. Contact them via Telegram. Worst case: funds return after timeout.

**Q: Why is [X payment method] locked?**
A: Some platforms require a minimum tier. PayPal needs Peer Plus ($2,000 volume). Build volume with other methods first.

**Q: What's the cheapest way to buy?**
A: I'll check live rates for you right now. [Query indexer and present results]
