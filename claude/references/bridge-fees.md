# Bridge Fees — Relay API, Architecture & On-Chain Findings

## BRIDGE ARCHITECTURE

Peer uses **Across Protocol** (via `AcrossBridgeHookV2` smart contract) for cross-chain bridging. **Relay.link** is the API/routing layer built on top of Across.

- For **EVM chains**: AcrossBridgeHook deposits USDC into the Across SpokePool. A relayer delivers tokens on the destination chain.
- For **Bitcoin (nativo)**: Relay handles the USDC->BTC swap. The relayer sends real BTC to the user's `bc1...` address on the Bitcoin network.
- Trust model: **optimistic** — relayers advance funds with economic guarantees enforced by UMA Oracle. Not a trusted third party, but not a trustless atomic swap either.
- Fallback: If the bridge fails, the user receives USDC on Base instead (graceful degradation, never loses funds).

## RELAY API — QUOTE ENDPOINT

Query exact bridge fees for non-Base destinations:

```bash
curl -sL -X POST "https://api.relay.link/quote/v2" \
  -H "Content-Type: application/json" \
  -d '{
    "user": "USER_EVM_ADDRESS",
    "originChainId": 8453,
    "originCurrency": "0x833589fcd6edb6e08f4c7c32d4f71b54bda02913",
    "destinationChainId": DEST_CHAIN_ID,
    "destinationCurrency": "DEST_TOKEN_ADDRESS",
    "recipient": "RECIPIENT_ADDRESS",
    "tradeType": "EXACT_INPUT",
    "amount": "AMOUNT_IN_USDC_BASE_UNITS"
  }'
```

Key parameters:
- `amount`: USDC in 6 decimals (e.g., `500000000` = 500 USDC)
- `originChainId`: Always `8453` (Base)
- `originCurrency`: Always `0x833589fcd6edb6e08f4c7c32d4f71b54bda02913` (USDC on Base)

## COMMON DESTINATIONS

| Destination | chainId | currency address | Example |
|-------------|---------|-----------------|---------|
| **Bitcoin (nativo)** | `8253038` | `bc1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqmql8k8` | BTC a direccion bc1... |
| Ethereum ETH | `1` | `0x0000000000000000000000000000000000000000` | ETH nativo |
| Solana SOL | `792703809` | `11111111111111111111111111111111` | SOL nativo |
| Arbitrum USDC | `42161` | `0xaf88d065e77c8cC2239327C5EDb3A432268e5831` | USDC en Arbitrum |
| Hyperliquid | `1337` | Check relay.link | USDC en Hyperliquid |
| Base USDC | `8453` | N/A — no bridge needed | Directo |

The Relay quote response contains exact fees in `fees.relayer` and `fees.gas`, plus the output amount in `details.currencyOut`. Use these real numbers instead of estimating.

**Always query Relay when the user wants a non-Base token.** Never estimate bridge fees — the API gives exact costs in real time.

## BITCOIN (BTC NATIVO) FLOW

Peer + Relay.link support **native BTC on the Bitcoin network** — not wrapped tokens. The flow:
1. USDC released from escrow on Base
2. Relay.link swaps USDC -> BTC and sends to the user's `bc1...` address
3. Total cost = spread + manager fee (0-0.1%) + Relay fee (~0.024%)
4. Time: ~4-6 minutes total

## ON-CHAIN FINDINGS (verified 2026-03-29)

### Contracts

- **EscrowV2**: Holds USDC deposits on Base
- **OrchestratorV1/V2**: Routes intents to escrow/bridge
- **AcrossBridgeHookV1**: `0x72C10b838Cf46649691949c285E0b468b363b9f0`
- **AcrossBridgeHookV2**: `0xCcC9163451DE31a625D48e417e0fD1a329c7f7cf`
- **SpokePool (Base)**: Across Protocol's entry point for cross-chain transfers

### Key findings

- **Peer does NOT charge any markup on bridge fees** — AcrossBridgeHook passes 100% of USDC to the SpokePool without retaining any amount (verified in contract code + on-chain tx traces)
- **Bitcoin chainId in Across on-chain**: `34268394551451` (different from Relay API's `8253038` — the API abstracts this)
- **Relay bridge fee measured from 13 real transactions**: ~0.024% average
- **Stats week of 22-29 Mar 2026**: 860 trades, $239K volume, 0 bridges to BTC (all USDC on Base)
- All bridge operations are via Across Protocol relayers — optimistic model with UMA Oracle dispute resolution

### Supported chains (Relay chainIds)

```
Base:        8453
Ethereum:    1
Arbitrum:    42161
Polygon:     137
Solana:      792703809
Bitcoin:     8253038
Hyperliquid: 1337
HyperEVM:    999
Scroll:      534352
Avalanche:   43114
BNB:         56
FlowEVM:     747
```
