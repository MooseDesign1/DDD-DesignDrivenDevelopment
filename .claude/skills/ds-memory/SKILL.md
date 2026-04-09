---
name: ds-memory
model: haiku
effort: low
description: >
  Read, write, and search persistent memory files. Use when the user types /ds-memory,
  asks to "check memory", "what do you remember", "update memory", or wants to manage
  the design system's persistent state.
---

# Memory Management

Read, write, and search the design system's persistent memory.

## Procedure

### Step 1 — Determine action
If not clear from the user's request, ask:
- **Read** — "Show me the current state of <file>"
- **Search** — "Do you have any feedback about <topic>?"
- **Write** — "Remember that <fact>"
- **Clean up** — "Remove outdated entries from <file>"

### Step 2 — Execute

**Read:**
Load the requested file(s) from `design-system/memory/` and present the content.

**Search:**
Search across all memory files for the topic. Check:
- `feedback_*.md` files for corrections/preferences
- `REGISTRY.md` for component-related memory
- `TOKEN-GAPS.md` for token-related memory
- `CONVENTIONS-LOG.md` for decisions
- `specs/` for component specs

Present all relevant results.

**Write:**
Determine the right file and format. Create a new feedback/memory file or update
an existing one. Follow the write-memory internal skill patterns.

**Clean up:**
Show what would be removed. Get confirmation before deleting/archiving.
Move to DECISIONS-ARCHIVE.md if appropriate.

### Step 3 — Update dashboard
Invoke write-memory to refresh MEMORY.md counts if anything changed.

## Rules
- Always confirm before deleting memory entries
- When archiving, move to DECISIONS-ARCHIVE.md rather than deleting
- Search is across ALL memory files, not just the one the user mentions
