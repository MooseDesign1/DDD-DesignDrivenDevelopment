#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ $# -lt 1 ]; then
  echo "Usage: ./uninstall.sh <project-path>"
  echo "  Removes the design agent from a project."
  exit 1
fi

PROJECT_PATH="$(cd "$1" && pwd)"
DS_DIR="$PROJECT_PATH/design-system"
SKILLS_DIR="$PROJECT_PATH/.claude/skills"
HOOKS_DIR="$PROJECT_PATH/.claude/hooks"
SETTINGS_FILE="$PROJECT_PATH/.claude/settings.json"
CLAUDE_MD="$PROJECT_PATH/CLAUDE.md"

echo "Uninstalling DDD from: $PROJECT_PATH"

# --- Step 1: Remove copied skills and version stamp ---
if [ -d "$SKILLS_DIR" ]; then
  for target in "$SKILLS_DIR"/ds-* "$SKILLS_DIR"/ddd-* "$SKILLS_DIR"/build-frame "$SKILLS_DIR"/resolve-token "$SKILLS_DIR"/resolve-component "$SKILLS_DIR"/validate-component "$SKILLS_DIR"/write-memory; do
    [ -e "$target" ] || continue
    skill_name="$(basename "$target")"
    rm -rf "$target"
    echo "  Removed $skill_name"
  done
  rm -f "$SKILLS_DIR/.ddd-version"
fi

# Clean up empty .claude/skills/ if we left it empty
if [ -d "$SKILLS_DIR" ] && [ -z "$(ls -A "$SKILLS_DIR")" ]; then
  rmdir "$SKILLS_DIR"
  echo "  Removed empty .claude/skills/"
fi

# --- Step 1b: Remove version-check hook ---
if [ -f "$HOOKS_DIR/ddd-version-check.sh" ]; then
  rm -f "$HOOKS_DIR/ddd-version-check.sh"
  echo "  Removed version-check hook"
fi
# Clean up empty .claude/hooks/ if we left it empty
if [ -d "$HOOKS_DIR" ] && [ -z "$(ls -A "$HOOKS_DIR")" ]; then
  rmdir "$HOOKS_DIR"
fi

# Remove DDD hook entry from .claude/settings.json
if [ -f "$SETTINGS_FILE" ]; then
  node -e "
const fs = require('fs');
const file = '$SETTINGS_FILE';
let settings = {};
try { settings = JSON.parse(fs.readFileSync(file, 'utf8')); } catch (e) { process.exit(0); }
if (!settings.hooks || !settings.hooks.SessionStart) process.exit(0);
settings.hooks.SessionStart = settings.hooks.SessionStart.filter(
  h => !(h.hooks && h.hooks.some(hh => hh.command && hh.command.includes('ddd-version-check')))
);
if (settings.hooks.SessionStart.length === 0) delete settings.hooks.SessionStart;
if (Object.keys(settings.hooks).length === 0) delete settings.hooks;
fs.writeFileSync(file, JSON.stringify(settings, null, 2) + '\n');
console.log('  Removed DDD hook from .claude/settings.json');
" 2>/dev/null || true
fi

# --- Step 2: Remove CLAUDE.md section ---
START_MARKER="# --- Design System Agent (DDD) ---"
END_MARKER="# --- End Design System Agent ---"
if [ -f "$CLAUDE_MD" ] && grep -qF "$START_MARKER" "$CLAUDE_MD"; then
  sed -i.bak "/$START_MARKER/,/$END_MARKER/d" "$CLAUDE_MD" && rm -f "$CLAUDE_MD.bak"
  sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD" && rm -f "$CLAUDE_MD.bak"
  echo "  Removed DDD section from CLAUDE.md"
fi

# --- Step 3: Note about design-system/ ---
if [ -d "$DS_DIR" ]; then
  echo ""
  echo "  NOTE: design-system/ directory was NOT removed (contains project data)."
  echo "  Delete manually if you no longer need it:"
  echo "    rm -rf $DS_DIR"
fi

echo ""
echo "Done."
