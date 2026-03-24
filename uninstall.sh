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
CLAUDE_MD="$PROJECT_PATH/CLAUDE.md"

echo "Uninstalling DDD from: $PROJECT_PATH"

# --- Step 1: Remove skill symlinks ---
if [ -d "$SKILLS_DIR" ]; then
  for target in "$SKILLS_DIR"/ds-* "$SKILLS_DIR"/build-frame "$SKILLS_DIR"/resolve-token "$SKILLS_DIR"/resolve-component "$SKILLS_DIR"/validate-component "$SKILLS_DIR"/write-memory; do
    [ -e "$target" ] || continue
    skill_name="$(basename "$target")"
    if [ -L "$target" ]; then
      rm "$target"
      echo "  Removed symlink: $skill_name"
    fi
  done
fi

# Clean up empty .claude/skills/ if we left it empty
if [ -d "$SKILLS_DIR" ] && [ -z "$(ls -A "$SKILLS_DIR")" ]; then
  rmdir "$SKILLS_DIR"
  echo "  Removed empty .claude/skills/"
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
