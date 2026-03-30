#!/usr/bin/env bash
# DDD version check — runs on session startup only.
# Compares installed version against npm registry; nudges if a newer version exists.
# Fails silently — never blocks Claude from starting.

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_FILE="$HOOK_DIR/../skills/.ddd-version"

# Read installed version stamp
[ -f "$VERSION_FILE" ] || exit 0
INSTALLED=$(cat "$VERSION_FILE" | tr -d '[:space:]')
[ -z "$INSTALLED" ] && exit 0

# Fetch latest version from npm registry (2s timeout, fail silently)
LATEST=$(node -e "
const https = require('https');
let data = '';
const req = https.get(
  'https://registry.npmjs.org/design-driven-development/latest',
  { timeout: 2000 },
  (res) => {
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      try { process.stdout.write(JSON.parse(data).version); } catch (e) {}
    });
  }
);
req.on('error', () => {});
req.on('timeout', () => req.destroy());
" 2>/dev/null || true)

# Exit silently if fetch failed or versions match
[ -z "$LATEST" ] && exit 0
[ "$INSTALLED" = "$LATEST" ] && exit 0

# Proper semver comparison via node
IS_NEWER=$(node -e "
const parse = v => v.split('.').map(Number);
const [a, b] = ['$INSTALLED', '$LATEST'].map(parse);
const newer =
  b[0] > a[0] ||
  (b[0] === a[0] && b[1] > a[1]) ||
  (b[0] === a[0] && b[1] === a[1] && b[2] > a[2]);
process.stdout.write(newer ? 'yes' : 'no');
" 2>/dev/null || echo "no")

[ "$IS_NEWER" = "yes" ] || exit 0

# Output nudge — captured by Claude Code as a system message
echo "🔔 DDD v$LATEST is available (installed: v$INSTALLED). Run /ddd-update to upgrade your skills."
