#!/usr/bin/env bash
# check-updates.sh — Detects changes in Peer platform vs skill reference data
# Run manually or via cron/GitHub Actions. Exits 0 if no changes, 1 if updates found.
#
# Usage: ./check-updates.sh [--verbose]

set -uo pipefail

INDEXER="https://indexer.hyperindex.xyz/8fd74dc/v1/graphql"
DOCS_SITEMAP="https://docs.peer.xyz/sitemap.xml"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERBOSE="${1:-}"

# Known hashes from reference file (source of truth for the skill)
KNOWN_METHODS=(
  "0x90262a3db0edd0be2369c6b28f9e8511ec0bac7136cefbada0880602f87e7268"  # venmo
  "0x617f88ab82b5c1b014c539f7e75121427f0bb50a4c58b187a238531e7d58605d"  # revolut
  "0x10940ee67cfb3c6c064569ec92c0ee934cd7afa18dd2ca2d6a2254fcb009c17d"  # cashapp
  "0x554a007c2217df766b977723b276671aee5ebb4adaea0edb6433c88b3e61dac5"  # wise
  "0x3ccc3d4d5e769b1f82dc4988485551dc0cd3c7a3926d7d8a4dde91507199490f"  # paypal
  "0x62c7ed738ad3e7618111348af32691b5767777fbaf46a2d8943237625552645c"  # monzo
  "0xa5418819c024239299ea32e09defae8ec412c03e58f5c75f1b2fe84c857f5483"  # mercadopago
  "0x817260692b75e93c7fbc51c71637d4075a975e221e1ebc1abeddfabd731fd90d"  # zelle-citi
  "0x6aa1d1401e79ad0549dced8b1b96fb72c41cd02b32a7d9ea1fed54ba9e17152e"  # zelle-chase
  "0x4bc42b322a3ad413b91b2fde30549ca70d6ee900eded1681de91aaf32ffd7ab5"  # zelle-bofa
  "0x5908bb0c9b87763ac6171d4104847667e7f02b4c47b574fe890c1f439ed128bb"  # chime
  "0xd9ff4fd6b39a3e3dd43c41d05662a5547de4a878bc97a65bcb352ade493cdc6b"  # n26
  "0xcac9daea62d7b89d75ac73af4ee14dcf25721012ae82b568c2ea5c808eaa04ff"  # alipay
)

KNOWN_CURRENCIES=(
  "0xc4ae21aac0c6549d71dd96035b7e0bdb6c79ebdba8891b666115bc976d16a29e"  # USD
  "0xfff16d60be267153303bbfa66e593fb8d06e24ea5ef24b6acca5224c2ca6b907"  # EUR
  "0x90832e2dc3221e4d56977c1aa8f6a6706b9ad6542fbbdaac13097d0fa5e42e67"  # GBP
  "0x221012e06ebf59a20b82e3003cf5d6ee973d9008bdb6e2f604faa89a27235522"  # CAD
  "0xcb83cbb58eaa5007af6cad99939e4581c1e1b50d65609c30f303983301524ef3"  # AUD
  "0xc9d84274fd58aa177cabff54611546051b74ad658b939babaad6282500300d36"  # CHF
  "0xa94b0702860cb929d0ee0c60504dd565775a058bf1d2a2df074c1db0a66ad582"  # MXN
  "0x8fd50654b7dd2dc839f7cab32800ba0c6f7f66e1ccf89b21c09405469c2175ec"  # ARS
  "0xdbd9d34f382e9f6ae078447a655e0816927c7c3edec70bd107de1d34cb15172e"  # NZD
  "0xc241cc1f9752d2d53d1ab67189223a3f330e48b75f73ebf86f50b2c78fe8df88"  # SGD
  "0xfe13aafd831cb225dfce3f6431b34b5b17426b6bff4fccabe4bbe0fe4adc0452"  # JPY
  "0xaad766fbc07fb357bed9fd8b03b935f2f71fe29fc48f08274bc2a01d7f642afc"  # INR
  "0xa156dad863111eeb529c4b3a2a30ad40e6dcff3b27d8f282f82996e58eee7e7d"  # HKD
  "0xfaaa9c7b2f09d6a1b0971574d43ca62c3e40723167c09830ec33f06cec921381"  # CNY
  "0x128d6c262d1afe2351c6e93ceea68e00992708cfcbc0688408b9a23c0c543db2"  # TRY
  "0x326a6608c2a353275bd8d64db53a9d772c1d9a5bc8bfd19dfc8242274d1e9dd4"  # THB
  "0x8895743a31faedaa74150e89d06d281990a1909688b82906f0eb858b37f82190"  # SEK
  "0x8fb505ed75d9d38475c70bac2c3ea62d45335173a71b2e4936bd9f05bf0ddfea"  # NOK
  "0x5ce3aa5f4510edaea40373cbe83c091980b5c92179243fe926cb280ff07d403e"  # DKK
  "0x9a788fb083188ba1dfb938605bc4ce3579d2e085989490aca8f73b23214b7c1d"  # PLN
  "0x7766ee347dd7c4a6d5a55342d89e8848774567bcf7a5f59c3e82025dbde3babb"  # HUF
  "0xe6c11ead4ee5ff5174861adb55f3e8fb2841cca69bf2612a222d3e8317b6ae06"  # PHP
  "0xf20379023279e1d79243d2c491be8632c07cfb116be9d8194013fb4739461b84"  # MYR
  "0x4dab77a640748de8588de6834d814a344372b205265984b969f3e97060955bfa"  # AED
  "0xf998cbeba8b7a7e91d4c469e5fb370cdfa16bd50aea760435dc346008d78ed1f"  # SAR
  "0x589be49821419c9c2fbb26087748bf3420a5c13b45349828f5cac24c58bbaa7b"  # KES
  "0x1fad9f8ddef06bf1b8e0e28c11b97ca0df51b03c268797e056b7c52e9048cfd1"  # UGX
  "0xe85548baf0a6732cfcc7fc016ce4fd35ce0a1877057cfec6e166af4f106a3728"  # VND
  "0x53611f0b3535a2cfc4b8deb57fa961ca36c7b2c272dfe4cb239a29c48e549361"  # ZAR
  "0xc681c4652bae8bd4b59bec1cdb90f868d93cc9896af9862b196843f54bf254b3"  # IDR
  "0x313eda7ae1b79890307d32a78ed869290aeb24cc0e8605157d7e7f5a69fea425"  # ILS
  "0xd783b199124f01e5d0dde2b7fc01b925e699caea84eae3ca92ed17377f498e97"  # CZK
  "0x2dd272ddce846149d92496b4c3e677504aec8d5e6aab5908b25c9fe0a797e25f"  # RON
)

CHANGES_FOUND=0
REPORT=""

log() { [[ "$VERBOSE" == "--verbose" ]] && echo "$1" || true; }
alert() { REPORT+="$1"$'\n'; CHANGES_FOUND=1; }

# ─── CHECK 1: New payment methods or currencies in indexer ───

log "Checking indexer for new hashes..."

INDEXER_RESPONSE=$(curl -sL --max-time 30 -X POST "$INDEXER" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ Deposit(limit: 200, where: {acceptingIntents: {_eq: true}, status: {_eq: \"ACTIVE\"}, remainingDeposits: {_gt: \"0\"}}) { currencies { currencyCode paymentMethodHash } } }"}' 2>/dev/null)

if [[ -z "$INDEXER_RESPONSE" ]] || echo "$INDEXER_RESPONSE" | grep -q '"errors"'; then
  alert "⚠️  INDEXER: Could not reach indexer or got error response"
else
  # Extract unique hashes
  LIVE_METHODS=$(echo "$INDEXER_RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
methods = set()
for d in data['data']['Deposit']:
    for c in d['currencies']:
        methods.add(c['paymentMethodHash'])
for m in sorted(methods):
    print(m)
" 2>/dev/null)

  LIVE_CURRENCIES=$(echo "$INDEXER_RESPONSE" | python3 -c "
import json, sys
data = json.load(sys.stdin)
currencies = set()
for d in data['data']['Deposit']:
    for c in d['currencies']:
        currencies.add(c['currencyCode'])
for c in sorted(currencies):
    print(c)
" 2>/dev/null)

  # Compare methods
  while IFS= read -r hash; do
    [[ -z "$hash" ]] && continue
    found=0
    for known in "${KNOWN_METHODS[@]}"; do
      [[ "$hash" == "$known" ]] && found=1 && break
    done
    [[ $found -eq 0 ]] && alert "🆕 NEW PAYMENT METHOD: $hash"
  done <<< "$LIVE_METHODS"

  # Compare currencies
  while IFS= read -r hash; do
    [[ -z "$hash" ]] && continue
    found=0
    for known in "${KNOWN_CURRENCIES[@]}"; do
      [[ "$hash" == "$known" ]] && found=1 && break
    done
    [[ $found -eq 0 ]] && alert "🆕 NEW CURRENCY: $hash"
  done <<< "$LIVE_CURRENCIES"

  log "  Indexer check done."
fi

# ─── CHECK 2: New pages in docs sitemap ───

log "Checking docs sitemap..."

# Known pages as of last update (2026-03-28)
KNOWN_PAGES_COUNT=69

SITEMAP=$(curl -sL --max-time 15 "$DOCS_SITEMAP" 2>/dev/null)
if [[ -z "$SITEMAP" ]]; then
  alert "⚠️  DOCS: Could not fetch sitemap"
else
  # Sitemap may be single-line XML — count <loc> occurrences, not lines
  CURRENT_COUNT=$(echo "$SITEMAP" | grep -oP '<loc>' | wc -l)
  if [[ $CURRENT_COUNT -gt $KNOWN_PAGES_COUNT ]]; then
    NEW_COUNT=$((CURRENT_COUNT - KNOWN_PAGES_COUNT))
    alert "📄 DOCS: $NEW_COUNT new page(s) in sitemap (was $KNOWN_PAGES_COUNT, now $CURRENT_COUNT)"
    # Show newest pages (last N entries)
    echo "$SITEMAP" | grep -oP '<loc>[^<]+</loc>' | sed 's/<[^>]*>//g' | tail -"$NEW_COUNT" | while read -r url; do
      alert "   → $url"
    done
  fi
  log "  Sitemap check done ($CURRENT_COUNT pages)."
fi

# ─── CHECK 3: SDK version ───

log "Checking SDK version..."

SDK_VERSION=$(npm view @zkp2p/sdk version 2>/dev/null || echo "unknown")
KNOWN_SDK_VERSION="0.2.3"

if [[ "$SDK_VERSION" != "unknown" ]] && [[ "$SDK_VERSION" != "$KNOWN_SDK_VERSION" ]]; then
  alert "📦 SDK: Version changed from $KNOWN_SDK_VERSION to $SDK_VERSION"
fi
log "  SDK check done (current: $SDK_VERSION)."

# ─── CHECK 4: Reputation page content hash ───

log "Checking reputation docs for changes..."

REP_PAGE=$(curl -sL --max-time 15 "https://docs.peer.xyz/guides/for-buyers/reputation" 2>/dev/null)
if [[ -n "$REP_PAGE" ]]; then
  # Count tier rows in the table — look for dollar cap amounts ($XXX or $X,XXX) near tier names
  TIER_ROWS=$(echo "$REP_PAGE" | grep -oP 'Peer (Peasant|Plus|Pro|Platinum|[A-Z][a-z]+)\$[0-9,]+' | wc -l)
  if [[ $TIER_ROWS -gt 5 ]]; then
    alert "🏅 TIERS: Found $TIER_ROWS tier rows (expected 5). New tier added?"
  fi

  # Check if cap numbers changed
  if ! echo "$REP_PAGE" | grep -q '\$5,000'; then
    alert "🏅 TIERS: Platinum cap ($5,000) not found — caps may have changed"
  fi
  if ! echo "$REP_PAGE" | grep -q '\$100'; then
    alert "🏅 TIERS: Peasant cap ($100) not found — caps may have changed"
  fi
fi
log "  Reputation check done."

# ─── CHECK 5: Payment methods in web FAQ ───

log "Checking peer.xyz FAQ..."

WEB_FAQ=$(curl -sL --max-time 15 "https://peer.xyz" 2>/dev/null)
if [[ -n "$WEB_FAQ" ]]; then
  FAQ_METHODS=$(echo "$WEB_FAQ" | grep -oP '"What payment methods does Peer support\?".*?"text":\s*"([^"]+)"' | head -1)
  if echo "$FAQ_METHODS" | grep -iqP 'luxon|pix|gpay|apple.pay|tikkie|mbway|bizum|gcash'; then
    alert "💳 WEB FAQ: New payment method detected in FAQ text"
    alert "   $FAQ_METHODS"
  fi
fi
log "  Web FAQ check done."

# ─── RESULTS ───

echo ""
echo "═══════════════════════════════════════════"
echo "  Peer Skill Update Check — $(date +%Y-%m-%d)"
echo "═══════════════════════════════════════════"

if [[ $CHANGES_FOUND -eq 0 ]]; then
  echo "✅ No changes detected. Skill is up to date."
else
  echo "⚠️  Changes detected:"
  echo ""
  echo "$REPORT"
  echo "Run 'coteja peer con la web' in Claude Code to investigate and update."
fi

exit $CHANGES_FOUND
