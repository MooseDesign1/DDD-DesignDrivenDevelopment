---
name: ddd-update
description: >
  Update DDD to the latest version. Triggered by /ddd-update, "update DDD",
  "update the design system agent", "upgrade DDD", "new DDD version available",
  or when the version nudge appears at session start. Reinstalls skills in-place
  without touching the knowledge-base or memory files.
---

# DDD Update

Upgrade DDD skills to the latest version in-place.

## Procedure

### Step 1 — Show current state
Read `design-system/config.md` → get `agent_version`.
Read `.claude/skills/.ddd-version` → get installed skills version.

Report:
```
Current:   v<agent_version>  (knowledge-base last synced)
Installed: v<installed>      (skills files on disk)
```

### Step 2 — Run the update
Run via Bash:
```bash
npx design-driven-development@latest .
```

This reinstalls all skill files from the latest npm package into `.claude/skills/`.
It does NOT touch `design-system/` — your knowledge-base, tokens, components, memory, and config are fully preserved.

If the Bash run fails (npx not found, network error, etc.), ask the user to run it manually in their terminal instead.

### Step 3 — Confirm and sync version
After the command completes:
1. Read `.claude/skills/.ddd-version` — confirm it now shows the new version
2. Update `design-system/config.md` → set `agent_version` to match
3. Invoke write-memory to update MEMORY.md

Report:
```
✦  DDD Updated

v<old> → v<new>

Skills refreshed in .claude/skills/.
Your knowledge-base and memory are untouched.

Run /ds-update if you want to re-scan your Figma file for design changes.
```

## Rules
- Never modify or delete anything in `design-system/` during an update
- If `npx` fails, surface the error and provide the manual command
- After update, always confirm the version stamp changed before reporting success
