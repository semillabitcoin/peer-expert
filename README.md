# peer-expert

Your AI assistant for buying crypto without KYC on [peer.xyz](https://peer.xyz). Queries live market data, finds the cheapest rates, and walks you through every step.

Works with **OpenClaw** and **Claude Code**.

## Why use this?

Peer is the fastest no-KYC crypto onramp — but choosing the right payment method, currency, and timing can save you 1-4% on every purchase. This skill does that for you automatically.

### Before peer-expert
> "I want to buy $500 of ETH"
> *Opens peer.xyz, picks Venmo because it's familiar, pays 1.5% spread + doesn't realize Revolut would have been 0.5%*

### With peer-expert
> "I want to buy $500 of ETH"
> *Skill queries live rates, tells you Revolut has 0.5% spread vs Venmo's 1.5%, calculates your total cost including bridge fees, and walks you through step by step*

**That's $5 saved on a single $500 purchase.** It adds up.

---

## What it can do

### 1. Find the best deal — in real time

Ask in any language. The skill queries the Peer indexer live and compares every payment method:

> **You**: quiero comprar 200 euros de Bitcoin
>
> **Skill**: Consulte las tasas en vivo. Tus mejores opciones:
> 1. Wise — 1.7% spread, ~2.7% total con bridge ($5.40 en fees)
> 2. Revolut — 3.3% spread, ~4.3% total ($8.60 en fees)
>
> Wise te ahorra $3.20 en esta compra. Procedo?

The skill breaks down **every fee**: spread (set by sellers) + 0.5% protocol fee + bridge fee (if you want tokens outside Base). No hidden costs.

### 2. Answer any question about Peer

> **You**: why is PayPal locked?
>
> **Skill**: PayPal requires Peer Plus tier — you need $2,000 in completed volume first. Fastest way: use Revolut (5x cap, no cooldown). At $1,250 per order you'd hit Plus in 2 orders.

> **You**: is my data safe?
>
> **Skill**: Yes. PeerAuth generates ZK proofs locally on your machine. Only the payment amount, recipient, and timestamp are shared — no bank details, no transaction history, no personal info. You can verify this yourself in Chrome DevTools Network tab.

### 3. Guide you step by step

From "I've never used Peer" to "crypto in my wallet" — one message at a time:

1. Helps you pick payment method, amount, currency, chain
2. Queries live rates and recommends the cheapest option
3. Walks through wallet connection (or social login — no wallet needed)
4. Guides payment with safety warnings (cross-currency = #1 mistake)
5. Explains PeerAuth verification
6. Troubleshoots if anything goes wrong

### 4. Troubleshoot problems

> **You**: verification failed, what do I do?
>
> **Skill**: Don't panic — your money is in on-chain escrow. Try: 1) Click "Try again", wait 30s. 2) Check PeerAuth is active. 3) Refresh and retry. After 3 fails, contact the seller via Telegram with your order ID and payment screenshot. Do NOT cancel the payment.

The skill knows every common issue: PeerAuth not connecting, wrong currency sent, cooldowns, order expiry, and how to recover from each one.

### 5. Detect new payment methods and currencies automatically

Peer adds new options regularly. The skill doesn't just rely on a static list — it queries the indexer and compares against known hashes. If a new payment method or currency appears, it flags it:

> **Skill**: I found a payment method with hash `0xabc...` that isn't in my known list — Peer may have added a new option. The rate is 1.2% spread with $8,000 liquidity. Check docs.peer.xyz or the Peer Telegram to identify it.

This means the skill stays useful even as Peer evolves without needing updates.

### 6. Show a complete cost breakdown (worked example)

The skill doesn't just say "1.5% fee". It walks through the full math so you know exactly what you're paying:

> **You**: quiero comprar €200 en BTC con Revolut
>
> **Skill**:
> - Rate: 0.952 EUR/USDC → €200 / 0.952 = ~210.08 USDC
> - Protocol fee: -1.05 USDC (0.5%)
> - USDC received: ~209.03 on Base
> - After BTC swap: ~208.40 USDC worth of BTC (~0.3% swap)
> - **Total fees: ~€4.60 (2.3%)**

### 7. Handle errors gracefully

If the Peer indexer is down or returns empty data, the skill:

1. Retries once
2. Falls back to the Quote API (`api.zkp2p.xyz`)
3. If both fail, tells you honestly and sends you to peer.xyz directly

It also filters out bad data: deposits with >20% spread (likely stale), zero rates, or <$10 liquidity are skipped automatically.

### 8. Check live trading activity

> **You**: is Peer active right now? Are people actually using it?
>
> **Skill**: Let me check... In the last hour: 12 trades completed, $4,200 total volume. Most active: Revolut (EUR) and Wise (GBP). Total platform liquidity: $127,000 across 45 deposits.

The skill queries recent fulfilled intents from the indexer. You can also join the [Telegram trade feed](https://t.me/zk_p2p) where a bot posts every completed trade in real time.

### 9. Help developers integrate Peer

> **You**: I want to add a "buy crypto" button to my dApp
>
> **Skill**: Use the @zkp2p/sdk package. Install with `npm install @zkp2p/sdk`, then use the embedded widget or Quote API. Full docs at developer.peer.xyz.

The skill knows the SDK basics, chain IDs, contract addresses, and API endpoints for developers building on top of Peer.

---

## Supported currencies

USD, EUR, GBP, CAD, AUD, CHF, MXN, ARS, NZD, SGD, JPY, INR, HKD, CNY, TRY, THB, SEK, NOK, DKK, PLN, HUF, PHP, MYR, AED, SAR, KES, UGX, VND, ZAR, IDR, ILS, CZK, RON — **33 currencies** total.

## Supported payment methods

Revolut, Wise, Venmo, CashApp, PayPal, Monzo, Zelle (Citi/Chase/BofA), MercadoPago, Chime, N26, Alipay — **13 methods** across low/medium/high risk tiers.

## Supported chains

Base (native), Ethereum, Arbitrum, Solana, Hyperliquid, HyperEVM, Polygon, Scroll, Avalanche, BNB, FlowEVM, and 20+ more.

## Installation

### OpenClaw

OpenClaw is a self-hosted AI assistant that connects to your messaging apps. The peer-expert skill works with any OpenClaw installation — whether on Umbrel, a VPS, a Raspberry Pi, or your local machine.

**Step 1 — Copy the skill files:**

```bash
# Find your OpenClaw skills directory (common locations below)
# Umbrel:      ~/umbrel/app-data/openclaw/skills/
# Docker:      Check your docker-compose volume mount for /skills
# Local:       ~/.openclaw/skills/
# Custom:      Whatever path you set in OPENCLAW_SKILLS_DIR

# Copy the skill
cp -r openclaw/ <YOUR_SKILLS_DIR>/peer-expert/
```

**Step 2 — Verify the structure:**

```
<YOUR_SKILLS_DIR>/peer-expert/
├── SKILL.md
└── references/
    └── indexer-queries.md
```

**Step 3 — Restart OpenClaw** (or start a new session).

**Step 4 — Test it:**

Send a message to your OpenClaw from any connected channel:
> "What's the cheapest way to buy $100 of crypto right now?"

The skill activates automatically when it detects questions about peer.xyz, buying crypto, or P2P onramping. You can also trigger it directly with `/peer_expert`.

**Works from any channel connected to your OpenClaw:** WhatsApp, Telegram, Discord, Slack, Signal, etc.

**Troubleshooting:**
- Skill not activating? Make sure the `SKILL.md` file is in the root of the skill folder, not nested inside another directory.
- OpenClaw needs internet access to query the Peer indexer (outbound HTTPS to `indexer.hyperindex.xyz`).
- If you're behind a firewall or using Tor, make sure the indexer endpoint is reachable.

### Claude Code

**Quick install (one command):**

```bash
git clone https://github.com/semillabitcoin/peer-expert.git /tmp/peer-expert && \
mkdir -p ~/.claude/skills/buy-on-peer/ && \
cp -r /tmp/peer-expert/claude/* ~/.claude/skills/buy-on-peer/ && \
rm -rf /tmp/peer-expert
```

**Or step by step:**

```bash
# 1. Clone the repo
git clone https://github.com/semillabitcoin/peer-expert.git
cd peer-expert

# 2. Copy the skill files
mkdir -p ~/.claude/skills/buy-on-peer/
cp -r claude/* ~/.claude/skills/buy-on-peer/

# 3. Clean up
cd .. && rm -rf peer-expert
```

**Restart Claude Code** (or start a new conversation), then test it:

Say "buy-on-peer" or ask about peer.xyz. Example:
> "What are the best rates to buy USDC with EUR right now?"

## How it works

The skill connects to Peer's public GraphQL indexer (no API key needed) to fetch:
- Live conversion rates and spreads for every currency/payment method pair
- Available liquidity per deposit
- Recent completed trades (volume indicator)
- Platform-wide stats (total liquidity, active deposits)

It then calculates the **total cost** (spread + 0.5% protocol fee + bridge fee if needed) and ranks your options. All data is real-time — never cached, never guessed.

If the indexer is unavailable, the skill falls back to the Quote API and tells you transparently if data is stale.

## Structure

```
peer-expert/
├── README.md
├── claude/
│   ├── SKILL.md                      # Claude Code skill
│   └── references/
│       └── indexer-queries.md        # GraphQL queries + hash mappings
└── openclaw/
    ├── SKILL.md                      # OpenClaw skill
    └── references/
        └── indexer-queries.md
```

## Community

- **App**: https://peer.xyz
- **Docs**: https://docs.peer.xyz
- **Trade feed (Telegram)**: https://t.me/zk_p2p
- **Support (Telegram)**: https://t.me/+XDj9FNnW-xs5ODNl
- **Twitter/X**: https://x.com/peerxyz
- **GitHub**: https://github.com/zkp2p
- **Developer portal**: https://developer.peer.xyz

## License

MIT
