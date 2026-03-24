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
  echo -e "${C1} ████████╗  ${C2}████████╗  ${C3}████████╗ ${R}"
  echo -e "${C1} ██╔═════╗  ${C2}██╔═════╗  ${C3}██╔═════╗ ${R}"
  echo -e "${C1} ██║    ██  ${C2}██║    ██  ${C3}██║    ██ ${R}"
  echo -e "${C1} ██║    ██  ${C2}██║    ██  ${C3}██║    ██ ${R}"
  echo -e "${C1} ██╚═════╝  ${C2}██╚═════╝  ${C3}██╚═════╝ ${R}"
  echo -e "${C1} ████████╔╝ ${C2}████████╔╝ ${C3}████████╔╝${R}"
  echo -e "${C1} ╚════════╝ ${C2}╚════════╝ ${C3}╚════════╝${R}"

  if [ -n "$version" ]; then
    echo -e "${DIM}  Design-Driven Development  v${version}${R}"
  else
    echo -e "${DIM}  Design-Driven Development${R}"
  fi
  echo ""
}

# ─── Mascot helpers ─────────────────────────────────────────────────────────

_mascot_colors() {
  P='\033[38;2;162;89;255m'     # #A259FF — purple body
  PB='\033[48;2;162;89;255m'    # #A259FF — purple fill
  W='\033[38;2;255;255;255m'    # white   — face + accents
  WD='\033[38;2;200;160;255m'   # soft lavender — wand / arrow
  DIM='\033[2m'
  R='\033[0m'
}

_print_tagline() {
  local tagline="${1:-}"
  echo ""
  [ -n "$tagline" ] && echo -e "  ${DIM}${tagline}${R}"
  echo ""
}

# ─── Mascot variants (5 lines each) ─────────────────────────────────────────

# Working — focused eyes, wand extended right
print_mascot_working() {
  _mascot_colors
  echo ""
  echo ""
  echo -e "   ${P}▄███████████▄${R}"
  echo -e "  ${P}█${PB}${W}  ◉       ◉  ${R}${P}█${R}${WD}────${W}✦${R}"
  echo -e "  ${P}█${PB}${W}      ▿      ${R}${P}█${R}"
  echo -e "   ${P}▀███████████▀${R}"
  echo -e "      ${P}▄█████▄${R}"
  _print_tagline "$1"
}

# Init — wide curious eyes, arms spread, ✦ floating top-right
print_mascot_init() {
  _mascot_colors
  echo ""
  echo ""
  echo -e "   ${P}▄███████████▄${R}  ${W}✦${R}"
  echo -e "  ${P}█${PB}${W}  ◕       ◕  ${R}${P}█${R}"
  echo -e "  ${P}█${PB}${W}      ‿      ${R}${P}█${R}"
  echo -e "   ${P}▀███████████▀${R}"
  echo -e "  ${P}╱${R}   ${P}▄█████▄${R}   ${P}╲${R}"
  _print_tagline "$1"
}

# Build — star eyes, big smile, arms raised with sparkles
print_mascot_build() {
  _mascot_colors
  echo ""
  echo ""
  echo -e "${W}✦${R}  ${P}╲${R}  ${P}▄███████████▄${R}  ${P}╱${R}  ${W}✦${R}"
  echo -e "    ${P}█${PB}${W}  ★       ★  ${R}${P}█${R}"
  echo -e "    ${P}█${PB}${W}      ◡      ${R}${P}█${R}"
  echo -e "     ${P}▀███████████▀${R}"
  echo -e "        ${P}▄█████▄${R}"
  _print_tagline "$1"
}

# Handoff — relaxed eyes, waving arm, trailing arrow
print_mascot_handoff() {
  _mascot_colors
  echo ""
  echo ""
  echo -e "   ${P}▄███████████▄${R}"
  echo -e "  ${P}█${PB}${W}  ◠       ◠  ${R}${P}█${R}${WD}── ${W}ノ${R}"
  echo -e "  ${P}█${PB}${W}      ▿      ${R}${P}█${R}"
  echo -e "   ${P}▀███████████▀${R}"
  echo -e "      ${P}▄█████▄${R}   ${WD}──›${R}"
  _print_tagline "$1"
}

# ─── Named flow variants ─────────────────────────────────────────────────────

print_ddd_init_complete() {
  print_mascot_init "I now have all your design system sauce  ✦"
}

print_ddd_build_complete() {
  print_mascot_build "Yay! another component built  ✦"
}

print_ddd_handoff_complete() {
  print_mascot_handoff "Packaged up and shipped!  ✦"
}
