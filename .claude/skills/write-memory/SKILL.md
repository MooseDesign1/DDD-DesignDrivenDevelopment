---
name: write-memory
description: >
  Internal skill for persisting changes to memory files at the end of every workflow.
  Called as the final step of all user-facing skills. Updates only files that changed
  during the session.
---

# Write Memory

Persist session changes to the design-system memory files.

## Procedure

### Step 1 — Determine what changed
Review the current session's actions and identify which memory files need updating:
- `REGISTRY.md` — if components were built, modified, or planned
- `TOKEN-GAPS.md` — if token gaps were logged
- `CONVENTIONS-LOG.md` — if new conventions were decided
- `DECISIONS-ARCHIVE.md` — if open decisions exceeded 5 (archive oldest)

### Step 2 — Write changes
For each file that changed:
1. Read current content
2. Apply the update (append row, update status, add entry)
3. Write back

### Step 3 — Update MEMORY.md dashboard
Always update the dashboard with:
- Current counts (components, tokens, styles, gaps)
- Last updated timestamp
- Recent activity entry for this session

### Step 4 — Report
Tell the calling skill what was written:
- "Updated REGISTRY.md: added FilterCard (built)"
- "Updated TOKEN-GAPS.md: 1 new gap logged"
- "Updated MEMORY.md: counts refreshed"

## Rules
- Only touch files that actually changed — do not rewrite unchanged files
- MEMORY.md counts are updated EVERY session end
- Never write to knowledge-base/ files (that's ds-init/ds-update only)
- Open decisions capped at 5 in any memory file → oldest auto-archived
