#!/usr/bin/env bash
# DDD banner — source this file and call print_ddd_banner [version]

print_ddd_banner() {
  local version="${1:-}"

  # Figma brand colors (24-bit ANSI true color)
  local C1='\033[38;2;10;207;131m'   # #0ACF83 — first  D
  local C2='\033[38;2;26;188;254m'   # #1ABCFE — second D
  local C3='\033[38;2;255;114;98m'   # #FF7262 — third  D
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
