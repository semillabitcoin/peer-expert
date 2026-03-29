# Troubleshooting + Privacy & Security

## VERIFICATION FAILED ("Proof Gen Failed")

1. Click "Try again" — wait 30 seconds
2. Check PeerAuth is active (icon in Chrome bar)
3. Refresh page, retry
4. After 3 failures -> contact seller via Telegram:
   - Order ID
   - Payment screenshot
   - Wallet address
   - Amount paid and expected
5. **DO NOT cancel payment while waiting**

## COMMON ISSUES

| Problem | Solution |
|---------|----------|
| PeerAuth not showing | Reinstall extension, refresh peer.xyz |
| "Extension not connected" | Click PeerAuth icon, allow permissions |
| Payment not in list | Wait a few minutes for payment to process, retry |
| Order expired | Create new order. If payment sent, contact seller |
| Wrong currency sent | You get proportional USDC minus penalty fee (Wise only) |
| Wrong amount sent | You get proportional USDC (e.g., sent 90% = receive 90%) |
| Cooldown active | Use a low-risk platform (Revolut, Wise) — they have no cooldown |
| PayPal locked | Need Peer Plus tier ($2,000 total volume). Use other methods first |
| Can't find seller Telegram | Check deposit details on Peer for their username |

## CROSS-CURRENCY ERRORS (CRITICAL)

This is the most common and dangerous mistake:

**WRONG**: Having Revolut set to USD account, sending EUR order
**WRONG**: Converting inside the payment app before sending
**RIGHT**: Send in the EXACT currency you selected on Peer

If they sent wrong currency on Wise: Peer handles it automatically with a small penalty. On other platforms: contact the seller for manual release.

## INDEXER DOWN OR EMPTY RESULTS

If the GraphQL indexer returns an error, times out, or returns empty data:

1. **Retry once** after 5 seconds — transient failures are common
2. **Try the Quote API** as fallback:

```bash
curl -sL -X POST "https://api.zkp2p.xyz/v2/quote/exact-fiat" \
  -H "Content-Type: application/json" \
  -d '{"paymentPlatforms": ["revolut", "wise"], "fiatCurrency": "USD", "exactFiatAmount": "100", "user": "0x0000000000000000000000000000000000000000", "recipient": "0x0000000000000000000000000000000000000000", "destinationChainId": 8453, "destinationToken": "0x833589fcd6edb6e08f4c7c32d4f71b54bda02913"}'
```

Note: The Quote API may reject zero addresses. Use it for rough estimates only.

3. **If both fail**, tell the user:
   - "The Peer indexer is currently unavailable. You can check rates directly at https://peer.xyz"
   - "Try again in a few minutes — the indexer usually recovers quickly"
   - Do NOT guess or use cached rates — always be transparent about data freshness

## EMPTY RESULTS FOR A CURRENCY

If a query returns deposits but no matching currencies:
- The currency may have no active liquidity right now
- Try broadening: remove the `currencyCode` filter and check what currencies ARE available
- Suggest alternative currencies or payment methods with active liquidity

## RATE SANITY CHECK

Before presenting rates to the user, verify they make sense:
- Spread > 20% is suspicious — likely stale or misconfigured deposit
- Rate of 0 or negative — skip this deposit
- Liquidity < $10 — not worth recommending, filter out

---

## LIQUIDITY PAGE OVERVIEW (peer.xyz/liquidity)

The Liquidity page shows an order-book style view of all active deposits:

| Column | Meaning |
|--------|---------|
| Price | Rate in fiat per 1 USDC (e.g., 1.0100 = you pay 1.01 USD per USDC) |
| Spread | Premium over market rate in % |
| Amount | USDC available at this price level |
| Total | Cumulative USDC available up to this price |
| APR | Estimated annual yield for providers at this spread |
| Providers | Payment methods accepted (icons) + "V" if Vault-managed |

Useful for buyers to understand market depth before placing an order, and for LPs deciding what spread to set.

---

## PRIVACY & SECURITY

### What Data is Exposed?

- **To the seller**: Only your payment app username/tag (Revtag, Venmo handle, etc.)
- **On-chain**: Only transaction amount, timestamp, and proof hash. No personal data
- **PeerAuth extension**: Processes everything locally. Redacts all data except required payment fields
- **No data stored across sessions**

### How to Verify Privacy

Tell users: "Open Chrome DevTools -> Network tab while using PeerAuth. You'll see no data leaves your browser except the ZK proof."

### Known Risks

- **Reversible payments**: Venmo/CashApp payments can be reversed within 90 days (ACH). PayPal has 180-day buyer protection. Revolut/Wise are instant and non-reversible (lowest risk)
- **Banking flags**: Avoid writing "crypto", "USDC", or "zkp2p" in payment notes. Use neutral descriptions
- **API changes**: If a payment platform changes their API, verification may temporarily fail. Governance updates the verifiers
- **Proxy centralization**: Currently the TLS proxy is run by ZKP2P (similar to single-sequencer L2s). Will decentralize over time

### Audits

- ZKSecurity: Reclaim circuits (zkTLS)
- Sherlock: V2 and V3 smart contracts
- Scroll: V3 smart contracts
