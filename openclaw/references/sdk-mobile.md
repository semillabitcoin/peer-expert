# SDK, Developer Integration, Mobile & Referrals

## @zkp2p/sdk

Peer offers a TypeScript SDK (v0.2.3+) for integrating P2P onramping and offramping into dApps:

```bash
npm install @zkp2p/sdk viem
```

**Docs**: https://docs.peer.xyz/developer/sdk

### Key SDK capabilities

- **Onramp extension**: Detect and connect the Peer browser extension for onramp flows
- **Offramp/deposit management**: Create and manage USDC deposits, configure payment methods and currencies
- **Quote API**: Get best rates programmatically
- **Intent operations**: Signal and fulfill intents
- **Vault and rate-manager flows**: Automated liquidity management
- **React hooks**: `@zkp2p/sdk/react` for component-level transaction UX

### Basic integration pattern

```typescript
import { Zkp2pClient } from '@zkp2p/sdk';
import { createWalletClient, custom } from 'viem';
import { base } from 'viem/chains';

const walletClient = createWalletClient({
  chain: base,
  transport: custom(window.ethereum),
});

const client = new Zkp2pClient({
  walletClient,
  chainId: base.id,
});

// Read deposits
const deposits = await client.getDeposits();
```

**Note**: `OfframpClient` is an alias of `Zkp2pClient` -- both work. The SDK API may change. Always check https://docs.peer.xyz/developer/sdk for the latest docs.

### When users ask about the SDK

- Point them to the developer portal first
- The SDK is best for dApp developers who want to embed Peer as an onramp
- For personal use, the web app at peer.xyz is simpler

---

## Referral Program

Peer has had referral campaigns at various points. The current status may change:
- Check https://peer.xyz for any active referral links or banners
- Check the Peer Twitter/X (@peerxyz) for announcements
- Some campaigns offered points/rewards for completed orders
- If the user asks about referrals and you're unsure, direct them to the Peer Telegram or Discord

## Points & Rewards

Peer has run point-based reward systems (similar to airdrop farming):
- Points earned per completed order
- Higher tiers may earn more points
- Points programs can start/stop -- check peer.xyz for current status
- Do NOT promise specific rewards or token airdrops -- this is speculative

## Mobile App

- Peer has a mobile app available -- the website shows a "DOWNLOAD APP" option alongside "OPEN APP"
- Check the App Store / Play Store for "Peer"
- The web app (peer.xyz) also works on mobile browsers
- If a user asks about mobile: "Peer has a mobile app available. Look for the 'Download App' button on peer.xyz, or search for it in your app store."
