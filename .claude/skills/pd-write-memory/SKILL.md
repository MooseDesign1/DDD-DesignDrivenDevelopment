---
name: pd-write-memory
model: haiku-4-5
description: >
  Internal skill for persisting product design session changes to project memory files.
  Called as the final step of all pd-* user-facing skills. Updates only files that
  changed during the session. Never invoked directly by the user.
---

# PD Write Memory

Persist session changes to product design project memory files.

---

## Step 1 — Determine what changed

Review the current session's actions. Identify which files need updating:

- `projects/<slug>/design/screen-inventory.md` — if screens were added, designed, or annotated
- `projects/<slug>/design/component-gaps.md` — if gaps were logged or resolved
- `projects/<slug>/design/directions.md` — if a concept direction was locked
- `projects/<slug>/design/flows.md` — if flows were defined or updated
- `projects/<slug>/design/research.md` — if discovery content was written
- `projects/<slug>/design/active_session.md` — always updated with current phase and checkpoint
- `projects/PROJECTS.md` — if project phase changed

---

## Step 2 — Write changes

For each file that changed:
1. Read current content
2. Apply the update (append row, update status, add phase block)
3. Write back

Do not rewrite files that were not touched.

---

## Step 3 — Update PROJECTS.md dashboard

Always update:
- Current phase for active project
- Last updated timestamp
- Status (in_progress / handoff-complete / archived)

---

## Step 4 — Report

Tell the calling skill what was written:
- "Updated screen-inventory.md: 3 screens marked as designed"
- "Updated component-gaps.md: 1 gap logged (DonorCard)"
- "Updated PROJECTS.md: phase advanced to DESIGN"

---

## Rules

- Only touch files that actually changed
- `active_session.md` is ALWAYS updated — it is the checkpoint
- Never write to `design-system/knowledge-base/` — that's ds-init/ds-update territory
- Never write to another project's memory folder
- PROJECTS.md phase is updated every session end
