#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION=$(cat "$SCRIPT_DIR/VERSION")

# --- Banner ---
# shellcheck source=assets/banner.sh
source "$SCRIPT_DIR/assets/banner.sh"
print_ddd_banner "$VERSION"

# --- Validate args ---
if [ $# -lt 1 ]; then
  echo "Usage: ./install.sh <project-path>"
  echo "  Installs the design agent into a project."
  exit 1
fi

PROJECT_PATH="$(cd "$1" && pwd)"
DS_DIR="$PROJECT_PATH/design-system"
SKILLS_DIR="$PROJECT_PATH/.claude/skills"
HOOKS_DIR="$PROJECT_PATH/.claude/hooks"
SETTINGS_FILE="$PROJECT_PATH/.claude/settings.json"
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
fi

# Scaffold projects/ directory (safe to run on updates — never overwrites existing projects)
if [ ! -d "$DS_DIR/projects" ]; then
  mkdir -p "$DS_DIR/projects"
  cp "$SCRIPT_DIR/templates/projects/PROJECTS.md" "$DS_DIR/projects/PROJECTS.md"
  echo "  Created design-system/projects/"
fi

# Always stamp agent_version (runs on fresh install and updates)
if [ -f "$DS_DIR/config.md" ]; then
  sed -i.bak "s/- agent_version: .*/- agent_version: $VERSION/" "$DS_DIR/config.md" && rm -f "$DS_DIR/config.md.bak"
  echo "  Updated agent_version to $VERSION in config.md"
fi

# --- Step 2: Copy skills (always overwrite to pick up updates) ---
mkdir -p "$SKILLS_DIR"
for skill_dir in "$SCRIPT_DIR/skills"/ds-* "$SCRIPT_DIR/skills"/ddd-* "$SCRIPT_DIR/skills"/pd-* "$SCRIPT_DIR/skills"/product-designer "$SCRIPT_DIR/skills"/build-frame "$SCRIPT_DIR/skills"/resolve-token "$SCRIPT_DIR/skills"/resolve-component "$SCRIPT_DIR/skills"/validate-component "$SCRIPT_DIR/skills"/write-memory "$SCRIPT_DIR/skills"/ddd-help "$SCRIPT_DIR/skills"/design-system-help "$SCRIPT_DIR/skills"/product-design-help; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DIR/$skill_name"
  rm -rf "$target"
  cp -r "$skill_dir" "$target"
  echo "  Installed $skill_name"
done

# Stamp installed version for update checks
echo "$VERSION" > "$SKILLS_DIR/.ddd-version"
echo "  Stamped version $VERSION"

# --- Step 2b: Install version-check hook ---
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/hooks/ddd-version-check.sh" "$HOOKS_DIR/ddd-version-check.sh"
chmod +x "$HOOKS_DIR/ddd-version-check.sh"
echo "  Installed version-check hook"

# Merge hook config into .claude/settings.json (create if missing, preserve existing config)
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi
node -e "
const fs = require('fs');
const file = '$SETTINGS_FILE';
let settings = {};
try { settings = JSON.parse(fs.readFileSync(file, 'utf8')); } catch (e) {}
if (!settings.hooks) settings.hooks = {};
if (!settings.hooks.SessionStart) settings.hooks.SessionStart = [];
const alreadyInstalled = settings.hooks.SessionStart.some(
  h => h.hooks && h.hooks.some(hh => hh.command && hh.command.includes('ddd-version-check'))
);
if (!alreadyInstalled) {
  settings.hooks.SessionStart.push({
    matcher: 'startup',
    hooks: [{ type: 'command', command: 'bash \".claude/hooks/ddd-version-check.sh\"' }]
  });
  fs.writeFileSync(file, JSON.stringify(settings, null, 2) + '\n');
  console.log('  Registered SessionStart hook in .claude/settings.json');
} else {
  console.log('  SessionStart hook already registered — skipping');
}
"

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
