# Selling Guide — Offramp / Providing Liquidity / Vaults

## SELLING FLOW (Offramp / Providing Liquidity)

Sellers deposit USDC into escrow and receive fiat payments passively — no need to be online to release funds.

### Why Sell on Peer?

- **Passive income**: Deposit USDC, set a spread, receive fiat to your payment app automatically
- **No manual release needed**: ZK proofs verify payments cryptographically — 99% of orders complete without seller interaction
- **High APR potential**: Even small spreads (0.5-1%) can yield >50% APR depending on volume
- **Flexible**: Accept multiple payment methods and currencies from a single deposit

### Step 1: Gather Requirements

Ask:
- How much USDC do they want to deposit?
- What payment platform(s)? (Revolut, Wise, Venmo, CashApp, PayPal, Monzo, MercadoPago, Zelle)
- What currencies do they want to accept?
- Do they have USDC on Base, or another chain?
- What spread are they targeting? (suggest checking Liquidity tab first)

### Step 2: Check Current Market

Before creating a deposit, the seller should review the Liquidity tab at peer.xyz:
- What spreads are other sellers charging?
- How much liquidity exists at each spread level?
- Which currencies/methods have the most demand?

Run the Liquidity Order Book Query from the indexer to show current market state.

### Step 3: Connect to Peer

```
1. Open https://peer.xyz
2. Click wallet icon (top-right)
3. Connect wallet (MetaMask, Rabby) OR sign in with Google/Email/Twitter
4. Click "Sell" tab or "Add Liquidity" button on the Order Book
```

### Step 4: Fund Account with USDC on Base

```
Option A -- Already have USDC on Base:
  -> Check balance in top-right corner. Ready to go.

Option B -- Have tokens on another chain:
  1. Click on "USDC" and choose a token from a major chain
  2. Enter your amount
  3. Enter a refund address (if using social login)
  4. Send tokens to the generated address (ONE-TIME USE only)
  5. Relay.link bridges and swaps automatically
  6. Wait for confirmation, then proceed to create deposit
```

### Step 5: Create Deposit

```
1. Click "New Deposit"
2. Enter USDC amount (or click Max for full balance)
3. (Optional) Enter Telegram username -- so buyers can contact you if issues arise
```

### Step 6: Configure Payment Platform

```
1. Select payment platform from dropdown:
   - Revolut (multi-currency), Wise (multi-currency), PayPal (multi-currency)
   - Venmo (USD), CashApp (USD), Zelle (USD)
   - Monzo (GBP), MercadoPago (ARS)
2. Enter your payee details:
   - Revolut: Revtag
   - Wise: Wisetag
   - Venmo: Username
   - CashApp: Cashtag
   - MercadoPago: CVU
   - etc.
3. Double-check accuracy -- this is how buyers send you money
```

### Step 7: Set Exchange Rates (ARM vs Manual)

Peer uses **Automated Rate Management (ARM)** by default — rates auto-update from Chainlink/Pyth oracles plus your spread.

```
EXPRESS FLOW (default -- Advanced toggle OFF):
  1. Set spread with +/- buttons (shown as % above/below market)
  2. Rate updates in real time as you adjust
  3. Done -- ARM handles pricing automatically

ADVANCED FLOW (Advanced toggle ON):
  1. Add multiple currencies (each with its own spread)
  2. Use spread slider (-5% to +5%)
  3. See orderbook chart showing your position vs other sellers
  4. (Optional) Set floor rate per currency -- minimum you'll accept
  5. Review configured rates summary
```

**Spread guidelines:**
| Currency type | Typical spread | Trade-off |
|--------------|---------------|-----------|
| Major (EUR, GBP, USD) | +0.5% to +1% | Fast fills, lower margin |
| Mid-range (CAD, AUD, SGD) | +1% to +2% | Balanced |
| Emerging (BRL, TRY, ARS, ZAR) | +1% to +3% | Higher margin, slower fills |

### Step 8: Configure Order Limits (Optional)

```
1. Click "Order Limits" to expand
2. Set minimum order size (e.g., 5 USDC)
3. Set maximum order size (up to your total deposit)
```

### Step 9: Add More Payment Platforms (Optional)

```
1. Click "Add Payment" (top-right)
2. Repeat Steps 6-7 for additional platforms
3. Each platform can have different currencies and spreads
```

### Step 10: Review and Approve

```
1. Verify: Are my tags correct? Are my spreads competitive?
2. Click "Approve" (first time) then confirm deposit transaction
3. Gas is sponsored if using social login
4. Wait 10-20 seconds for confirmation
```

### Step 11: Monitor Deposit

```
1. Go to "Sell" tab to see your active deposit
2. You'll see: total amount, remaining balance, accepted currencies/platforms, status
3. Fiat payments arrive in your payment app automatically
4. Rebalance fiat back into USDC every few days to keep liquidity available
```

### ARM Dashboard

For advanced monitoring, use **arm.peer.xyz**:
- **Feeds tab**: Oracle health status (Chainlink/Pyth) — if a feed goes down, your deposit pauses for that currency automatically
- **Deposits tab**: Market overview — all deposits by method and currency
- **Keeper tab**: Pyth feed keeper status — rarely an issue

### Floor Rates (Protection)

Set a floor rate to protect against market drops:

```
1. Enable Advanced flow
2. Toggle "Floor" on at bottom of rate panel
3. Enter minimum rate (e.g., 1.01 USD/USDC)
4. Red "Min" line appears on orderbook chart
5. Protocol uses higher of: ARM rate or floor rate
```

**When to use floors:**
- You have a known cost basis and need to sell above it
- Volatile currencies (emerging markets)
- Want to opt out of ARM entirely — set floor above ARM rate for fixed pricing

### Handling Manual Releases

99% of orders auto-complete via ZK proofs. Manual release is needed only when:
- Buyer sent wrong amount or wrong currency
- Buyer's proof generation failed (rare)

```
To manually release:
1. Buyer contacts you via Telegram with order details + payment proof
2. Log into your payment app -- verify payment matches the order
3. Cross-reference with your deposit details on Peer
4. Go to deposit details -> find the order -> click "Release"
5. Review warning, confirm amount and buyer address
6. Sign transaction -> funds released to buyer
```

**Red flags (do NOT release):**
- Buyer can't provide payment confirmation
- Amount doesn't match locked funds
- Multiple people claim same transaction
- Buyer is overly pushy or creates urgency

### Updating Rates

```
1. Go to Sell tab -> click your deposit
2. Click edit (pencil icon) next to the currency rate
3. Enter new rate or adjust spread
4. Confirm transaction -- new rate applies immediately
```

### APR Calculation

```
APR = (spread x 365 / daysPerCycle) x 100%

Where:
  daysPerCycle = Platform Liquidity / Platform Daily Volume
  spread = (Your Rate - Market Rate) / Market Rate
```

Example: $10,000 deposit, 3.33% spread, 10-day cycle = ~121% APR. Higher spreads earn more per trade but fill less often.

### Seller Tips

- **Start small** — deposit a small amount first to understand the flow
- **Check Liquidity tab** regularly to stay competitive
- **Lower spread = faster fills** (0.5-1%), **higher spread = more profit per trade** (1-3%)
- **Use ARM** unless you have strong market views — manual rates go stale fast
- **Monitor fill rate** — filling instantly means you're too cheap, sitting idle means too expensive
- **Rebalance regularly** — convert fiat back to USDC to keep your deposit active
- **Set floor rates** on volatile currencies for protection
- **Multiple platforms** on one deposit = more potential buyers

---

## VAULTS (Yield for Liquidity Providers)

### What are Vaults?

Vaults are a way for liquidity providers to earn yield automatically on their USDC deposits. Instead of managing deposits manually, users can delegate their liquidity to a Vault that handles pricing, rebalancing, and order matching.

### Key details

- **Access**: https://peer.xyz/vaults
- **How it works**: You deposit USDC into a Vault. The Vault places and manages orders on your behalf, adjusting spreads and accepting payments automatically.
- **APR**: Varies by spread level. Based on the Liquidity page data:
  - 0.10% spread -> ~22.6% APR
  - 0.59% spread -> ~29.0% APR
  - 1.00% spread -> ~56.4% APR
  - 1.50-2.00% spread -> ~85-115% APR
  - Higher spreads show even higher APR but may fill less often
- **Vault deposits are marked with "V"** in the Liquidity page order book

### When to recommend Vaults

- User is a liquidity provider or wants to earn yield on USDC
- User asks about passive income, staking, or yield on Peer
- User asks "how do I become a seller/maker on Peer?"

### What to tell users about Vaults

- Vaults are in Beta — smart contract risk applies
- APR is not guaranteed — it depends on trade volume and spread settings
- Higher spread = higher APR per trade, but fewer trades may fill
- Lower spread = more trades fill, but lower APR per trade
- Check https://peer.xyz/vaults for current Vault options and APR
