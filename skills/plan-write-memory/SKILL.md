---
name: plan-write-memory
model: haiku
effort: low
description: >
  Internal skill for persisting planner session changes to project plan files.
  Called as the final step of all plan-* user-facing skills. Updates only files that
  changed during the session. Never invoked directly by the user.
---

# Plan Write Memory

Persist session changes to project plan files.

---

## Step 1 — Determine what changed

Review the current session's actions. Identify which files need updating:

- `DDD/projects/<slug>/plan/master-plan.md` — if phases, features, or gates were added/updated
- `DDD/projects/<slug>/plan/features/<feature>.md` — if a feature was planned (Pass 1 or Pass 2)
- `DDD/projects/<slug>/plan/active_session.md` — always updated with current skill and checkpoint
- `DDD/projects/PROJECTS.md` — if project status or phase changed

---

## Step 2 — Write changes

For each file that changed:
1. Read current content
2. Apply the update (add section, update status, append feature)
3. Write back

Do not rewrite files that were not touched.

---

## Step 3 — Update active_session.md

Always update with:
```markdown
# Active Session

agent: planner
project: <slug>
skill: <plan-project | plan-feature>
status: <in_progress | complete>
session_started: <date>
last_updated: <date>

## Completed
- <what was done this session>

## Current
- <what step we're on, if in_progress>
- feature: <feature slug, if plan-feature>
- pass: <1 | 2, if plan-feature>
```

---

## Step 4 — Update PROJECTS.md

Always update:
- Current phase for active project
- Last updated timestamp
- Status (planning | active | complete)

---

## Step 5 — Report

Tell the calling skill what was written:
- "Updated master-plan.md: 3 phases, 8 features, 2 gates"
- "Created features/auth-login.md: Pass 1 complete"
- "Updated PROJECTS.md: status → active"

---

## Rules

- Only touch files that actually changed — do not rewrite unchanged files
- `active_session.md` is ALWAYS updated — it is the checkpoint
- Never write to `DDD/projects/<slug>/design/` — that's PD territory
- Never write to `DDD/projects/<slug>/handoff/` — that's PD output
- Never write to `DDD/projects/<slug>/dev/` — that's executor territory
- Never write to `design-system/` — that's DS territory
- PROJECTS.md status is updated every session end
