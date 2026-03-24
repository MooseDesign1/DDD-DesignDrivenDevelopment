#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION=$(cat "$SCRIPT_DIR/VERSION")

# --- Validate args ---
if [ $# -lt 1 ]; then
  echo "Usage: ./install.sh <project-path>"
  echo "  Installs the design agent into a project."
  exit 1
fi

PROJECT_PATH="$(cd "$1" && pwd)"
DS_DIR="$PROJECT_PATH/design-system"
SKILLS_DIR="$PROJECT_PATH/.claude/skills"
CLAUDE_MD="$PROJECT_PATH/CLAUDE.md"

echo "Installing DDD v$VERSION into: $PROJECT_PATH"

# --- Step 1: Scaffold design-system/ ---
if [ -d "$DS_DIR" ]; then
  echo "  design-system/ already exists — skipping scaffold"
else
  echo "  Creating design-system/ from templates..."
  cp -r "$SCRIPT_DIR/templates" "$DS_DIR"
  # Remove the CLAUDE.md injection template (it's only used for appending, not scaffolding)
  rm -f "$DS_DIR/claude-md-section.md"
  # Stamp version into config
  sed -i.bak "s/- agent_version: .*/- agent_version: $VERSION/" "$DS_DIR/config.md" && rm -f "$DS_DIR/config.md.bak"
fi

# --- Step 2: Symlink skills ---
mkdir -p "$SKILLS_DIR"
for skill_dir in "$SCRIPT_DIR/skills"/ds-* "$SCRIPT_DIR/skills"/build-frame "$SCRIPT_DIR/skills"/resolve-token "$SCRIPT_DIR/skills"/resolve-component "$SCRIPT_DIR/skills"/validate-component "$SCRIPT_DIR/skills"/write-memory; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DIR/$skill_name"
  if [ -L "$target" ]; then
    echo "  Symlink $skill_name already exists — skipping"
  elif [ -e "$target" ]; then
    echo "  WARNING: $skill_name exists but is not a symlink — skipping"
  else
    ln -s "$skill_dir" "$target"
    echo "  Linked $skill_name"
  fi
done

# --- Step 3: Append CLAUDE.md section ---
MARKER="# --- Design System Agent (DDD) ---"
if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER" "$CLAUDE_MD"; then
  echo "  CLAUDE.md already has DDD section — skipping"
else
  echo "  Appending design system section to CLAUDE.md..."
  [ -f "$CLAUDE_MD" ] && echo "" >> "$CLAUDE_MD"
  cat "$SCRIPT_DIR/templates/claude-md-section.md" >> "$CLAUDE_MD"
fi

echo ""
echo "Done! Start a Claude Code session in $PROJECT_PATH."
echo "The agent will auto-run /ds-init on first conversation."
