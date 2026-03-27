#!/usr/bin/env bash
# ddd-statusline.sh — DDD Status Line for Claude Code
# Shows: context window progress bar | usage limit | DDD update nudge
#
# Claude Code sends JSON data via stdin after each message. Fields used:
#   context_window.used_percentage    — 0-100 percent of context consumed
#   rate_limits.five_hour.used_percentage — 0-100 (Pro/Max only, else absent)
#
# Update check is cached for 5 minutes to avoid blocking on network.

# ── Colors ────────────────────────────────────────────────────────────────────
R='\033[0m'
G='\033[32m'   # green
Y='\033[33m'   # yellow
RE='\033[31m'  # red

# ── Paths ─────────────────────────────────────────────────────────────────────
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_FILE="$HOOK_DIR/../skills/.ddd-version"
CACHE_FILE="/tmp/ddd-sl-version.cache"

# ── Read stdin JSON ───────────────────────────────────────────────────────────
INPUT=$(cat)

# ── Parse context % and limit % in one node call ──────────────────────────────
PARSED=$(printf '%s' "$INPUT" | node -e "
var d='';
process.stdin.on('data',function(c){d+=c;});
process.stdin.on('end',function(){
  try{
    var j=JSON.parse(d);
    var ctx=Math.round((j.context_window&&j.context_window.used_percentage)||0);
    var lim=(j.rate_limits&&j.rate_limits.five_hour&&
             typeof j.rate_limits.five_hour.used_percentage==='number')
      ? Math.round(j.rate_limits.five_hour.used_percentage) : -1;
    process.stdout.write(ctx+' '+lim);
  }catch(e){process.stdout.write('0 -1');}
});
" 2>/dev/null || echo '0 -1')

CTX_PCT=$(echo "$PARSED" | cut -d' ' -f1); CTX_PCT=${CTX_PCT:-0}
LIM_PCT=$(echo "$PARSED" | cut -d' ' -f2); LIM_PCT=${LIM_PCT:--1}

# ── Context Window Progress Bar ───────────────────────────────────────────────
if   [ "$CTX_PCT" -ge 80 ] 2>/dev/null; then CTX_COL=$RE
elif [ "$CTX_PCT" -ge 50 ] 2>/dev/null; then CTX_COL=$Y
else                                          CTX_COL=$G
fi

FILLED=$(( CTX_PCT * 10 / 100 )); BAR=""; i=1
while [ $i -le 10 ]; do
  [ $i -le "$FILLED" ] && BAR="${BAR}▓" || BAR="${BAR}░"
  i=$(( i + 1 ))
done

CONTEXT_PART="${CTX_COL}${BAR} ${CTX_PCT}%${R}"

# ── Usage Limit ───────────────────────────────────────────────────────────────
LIMIT_PART=""
if [ "$LIM_PCT" -ge 0 ] 2>/dev/null; then
  if   [ "$LIM_PCT" -ge 80 ] 2>/dev/null; then LC=$RE
  elif [ "$LIM_PCT" -ge 50 ] 2>/dev/null; then LC=$Y
  else                                          LC=$G
  fi
  LIMIT_PART="  ·  ${LC}${LIM_PCT}% limit${R}"
fi

# ── DDD Update Nudge (cached, non-blocking) ───────────────────────────────────
UPDATE_PART=""
if [ -f "$VERSION_FILE" ]; then
  INSTALLED=$(tr -d '[:space:]' < "$VERSION_FILE")

  # Check cache age and read latest (all in one node call for speed)
  CACHE_RESULT=$(node -e "
var fs=require('fs');
var cacheAge=99999;
var latest='';
try{var m=fs.statSync('$CACHE_FILE').mtimeMs;cacheAge=Math.floor((Date.now()-m)/1000);}catch(e){}
try{latest=fs.readFileSync('$CACHE_FILE','utf8').trim();}catch(e){}
process.stdout.write(cacheAge+' '+latest);
" 2>/dev/null || echo "99999 ")

  CACHE_AGE=$(echo "$CACHE_RESULT" | cut -d' ' -f1)
  LATEST=$(echo "$CACHE_RESULT" | cut -d' ' -f2-)
  LATEST=$(echo "$LATEST" | tr -d '[:space:]')

  # Kick off async cache refresh when stale — never blocks the status line
  if [ "${CACHE_AGE:-99999}" -ge 300 ]; then
    (node -e "
var https=require('https'),d='';
var req=https.get('https://registry.npmjs.org/design-driven-development/latest',
  {timeout:2000},function(res){
    res.on('data',function(c){d+=c;});
    res.on('end',function(){
      try{require('fs').writeFileSync('$CACHE_FILE',JSON.parse(d).version);}catch(e){}
    });
  });
req.on('error',function(){});req.on('timeout',function(){req.destroy();});
" 2>/dev/null) &
    disown $! 2>/dev/null || true
  fi

  # Semver compare installed vs latest
  if [ -n "$LATEST" ] && [ -n "$INSTALLED" ] && [ "$INSTALLED" != "$LATEST" ]; then
    IS_NEWER=$(node -e "
var parse=function(v){return v.split('.').map(Number);};
var a=parse('$INSTALLED'),b=parse('$LATEST');
process.stdout.write((b[0]>a[0]||(b[0]===a[0]&&b[1]>a[1])||(b[0]===a[0]&&b[1]===a[1]&&b[2]>a[2]))?'yes':'no');
" 2>/dev/null || echo "no")
    [ "$IS_NEWER" = "yes" ] && UPDATE_PART="  ·  ${Y}/ddd-update (v${LATEST} available)${R}"
  fi
fi

# ── Output ────────────────────────────────────────────────────────────────────
printf '%b\n' "${CONTEXT_PART}${LIMIT_PART}${UPDATE_PART}"
