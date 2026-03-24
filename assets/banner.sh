#!/usr/bin/env bash
# DDD banner — source this file and call the relevant function

# ─── DDD Logo ───────────────────────────────────────────────────────────────

print_ddd_banner() {
  local version="${1:-}"

  local C1='\033[38;2;10;207;131m'    # #0ACF83 — first  D
  local C2='\033[38;2;26;188;254m'    # #1ABCFE — second D
  local C3='\033[38;2;255;114;98m'    # #FF7262 — third  D
  local DIM='\033[2m'
  local R='\033[0m'

  echo ""
  echo -e "${C1} ██████╗ ${C2}██████╗ ${C3}██████╗ ${R}"
  echo -e "${C1} ██╔══██╗${C2}██╔══██╗${C3}██╔══██╗${R}"
  echo -e "${C1} ██║  ██║${C2}██║  ██║${C3}██║  ██║${R}"
  echo -e "${C1} ██║  ██║${C2}██║  ██║${C3}██║  ██║${R}"
  echo -e "${C1} ██████╔╝${C2}██████╔╝${C3}██████╔╝${R}"
  echo -e "${C1} ╚═════╝ ${C2}╚═════╝ ${C3}╚═════╝ ${R}"

  if [ -n "$version" ]; then
    echo -e "${DIM}  Design-Driven Development  v${version}${R}"
  else
    echo -e "${DIM}  Design-Driven Development${R}"
  fi
  echo ""
}

# ─── Mascot ─────────────────────────────────────────────────────────────────
# Working: focused, wand raised. Done: celebrating, sparkles.

print_mascot_working() {
  local tagline="${1:-}"

  local P='\033[38;2;162;89;255m'     # #A259FF — purple body
  local PB='\033[48;2;162;89;255m'    # #A259FF — purple fill (background)
  local W='\033[38;2;255;255;255m'    # white   — face features
  local WD='\033[38;2;200;160;255m'   # soft purple — wand stick
  local DIM='\033[2m'
  local R='\033[0m'

  echo -e "   ${P}▄███████████▄${R}"
  echo -e "  ${P}█${PB}${W}  ·       ·  ${R}${P}█${R}"
  echo -e "  ${P}█${PB}${W}  ◉       ◉  ${R}${P}█${R}${WD}────${W}✦${R}"
  echo -e "  ${P}█${PB}${W}      ▿      ${R}${P}█${R}"
  echo -e "   ${P}▀███████████▀${R}"
  echo -e "      ${P}▄█████▄${R}"
  echo -e "     ${P}█       █${R}"

  if [ -n "$tagline" ]; then
    echo ""
    echo -e "  ${DIM}${tagline}${R}"
  fi
  echo ""
}

print_mascot_done() {
  local tagline="${1:-}"

  local P='\033[38;2;162;89;255m'     # #A259FF — purple body
  local PB='\033[48;2;162;89;255m'    # #A259FF — purple fill (background)
  local W='\033[38;2;255;255;255m'    # white   — face features + sparkles
  local DIM='\033[2m'
  local R='\033[0m'

  echo -e "${W}✦${R}   ${P}▄███████████▄${R}   ${W}✦${R}"
  echo -e "   ${P}█${PB}${W}  ─       ─  ${R}${P}█${R}"
  echo -e "   ${P}█${PB}${W}  ◠       ◠  ${R}${P}█${R}"
  echo -e "   ${P}█${PB}${W}      ◡      ${R}${P}█${R}"
  echo -e "    ${P}▀███████████▀${R}"
  echo -e "       ${P}▄█████▄${R}"
  echo -e "      ${P}█       █${R}"

  if [ -n "$tagline" ]; then
    echo ""
    echo -e "  ${DIM}${tagline}${R}"
  fi
  echo ""
}

# ─── Convenience: named flow variants ───────────────────────────────────────

print_ddd_init_complete() {
  print_mascot_done "I now have all your design system sauce  ✦"
}

print_ddd_build_complete() {
  print_mascot_done "Yay! another component built  ✦"
}

print_ddd_handoff_complete() {
  print_mascot_done "Packaged up and shipped!  ✦"
}
