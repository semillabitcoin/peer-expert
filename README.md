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

## What it can do

### Find the best deal — in real time

Ask in any language. The skill queries the Peer indexer live and compares every payment method:

> **You**: quiero comprar 200 euros de Bitcoin
>
> **Skill**: Consulte las tasas en vivo. Tus mejores opciones:
> 1. Wise — 1.7% spread, ~2.7% total con bridge ($5.40 en fees)
> 2. Revolut — 3.3% spread, ~4.3% total ($8.60 en fees)
>
> Wise te ahorra $3.20 en esta compra. Procedo?

### Answer any question about Peer

> **You**: why is PayPal locked?
>
> **Skill**: PayPal requires Peer Plus tier — you need $2,000 in completed volume first. Fastest way: use Revolut (5x cap, no cooldown). At $1,250 per order you'd hit Plus in 2 orders.

> **You**: is my data safe?
>
> **Skill**: Yes. PeerAuth generates ZK proofs locally on your machine. Only the payment amount, recipient, and timestamp are shared — no bank details, no transaction history, no personal info. You can verify this yourself in Chrome DevTools Network tab.

### Guide you step by step

From "I've never used Peer" to "crypto in my wallet" — one message at a time:

1. Helps you pick payment method, amount, currency, chain
2. Queries live rates and recommends the cheapest option
3. Walks through wallet connection (or social login — no wallet needed)
4. Guides payment with safety warnings (cross-currency = #1 mistake)
5. Explains PeerAuth verification
6. Troubleshoots if anything goes wrong

### Troubleshoot problems

> **You**: verification failed, what do I do?
>
> **Skill**: Don't panic — your money is in on-chain escrow. Try: 1) Click "Try again", wait 30s. 2) Check PeerAuth is active. 3) Refresh and retry. After 3 fails, contact the seller via Telegram with your order ID and payment screenshot. Do NOT cancel the payment.

## Supported currencies

USD, EUR, GBP, CAD, AUD, CHF, MXN, ARS, NZD, SGD, JPY, INR, HKD, CNY, TRY, THB, SEK, NOK, DKK, PLN, HUF, PHP, MYR, AED, SAR, and more — **33 currencies** total.

## Supported payment methods

Revolut, Wise, Venmo, CashApp, PayPal, Monzo, Zelle (Citi/Chase/BofA), MercadoPago, N26, Alipay — **12 methods** across low/medium/high risk tiers.

## Installation

### OpenClaw (Umbrel)

```bash
cp -r openclaw/ ~/.openclaw/skills/peer-expert/
```

Start a new session. Ask anything about buying crypto or say `/peer_expert`.

Works from **WhatsApp, Telegram, Discord, Slack, Signal** — any channel connected to your OpenClaw.

### Claude Code

```bash
cp -r claude/ ~/.claude/skills/buy-on-peer/
```

Restart Claude Code. Say `/peer-expert` or ask about peer.xyz.

## How it works

The skill connects to Peer's public GraphQL indexer (no API key needed) to fetch:
- Live conversion rates and spreads for every currency/payment method pair
- Available liquidity per deposit
- Platform status

It then calculates the **total cost** (spread + 0.5% protocol fee + bridge fee if needed) and ranks your options. All data is real-time — never cached, never guessed.

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

## License

MIT
