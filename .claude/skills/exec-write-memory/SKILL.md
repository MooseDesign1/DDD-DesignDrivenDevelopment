---
name: exec-write-memory
model: haiku-4-5
effort: medium
description: >
  Internal skill for persisting executor session changes to project dev files.
  Called as the final step of all exec-* user-facing skills. Updates only files that
  changed during the session. Never invoked directly by the user.
---

# Exec Write Memory

Persist session changes to `projects/<slug>/dev/` files.

---

## Step 1 — Determine what changed

Review the current session's actions. Identify which files need updating:

- `projects/<slug>/dev/status.md` — if any feature stage progressed
- `projects/<slug>/dev/active_session.md` — always updated with current skill and checkpoint
- `projects/PROJECTS.md` — if project status changed (e.g., first feature started building)

---

## Step 2 — Write or update status.md

If `status.md` doesn't exist, create it:

```markdown
# Dev Status: <Project Name>

> Last updated: <date>

| Feature | DS Gaps | Backend | Frontend | Status |
|---------|---------|---------|----------|--------|
```

Update the row for the active feature:

- Stage values: `not-started` | `in-progress` | `complete` | `skipped` | `—` (no tasks)
- Status values: `queued` | `building` | `verifying` | `blocked` | `complete`

If the feature row doesn't exist, append it.

---

## Step 3 — Update active_session.md

Always update with:

```markdown
# Active Session

agent: executor
project: <slug>
skill: <exec-feature | exec-map>
status: <in_progress | complete>
session_started: <date>
last_updated: <date>

## Feature
- name: <feature name>
- slug: <feature slug>
- branch: exec/<feature-slug>

## Current Stage
- stage: <ds-gaps | backend | frontend | verification | complete>
- task: <current task title or "all complete">
- task_index: <n of m>

## Completed
- <what was done this session>

## Remaining
- <what's left>
```

---

## Step 4 — Update PROJECTS.md

If the project's status should change:
- First feature starts building → project status: `in-development`
- All features complete → project status: `dev-complete`

Update the last-updated timestamp.

---

## Step 5 — Report

Tell the calling skill what was written:
- "Updated status.md: auth-login backend complete, frontend in-progress"
- "Updated active_session.md: exec-feature, stage backend, task 2/3"
- "Updated PROJECTS.md: status → in-development"

---

## Rules

- Only touch files that actually changed — do not rewrite unchanged files
- `active_session.md` is ALWAYS updated — it is the checkpoint
- `status.md` is the gate signal — planner reads this for auto-detection
- Never write to `projects/<slug>/plan/` — that's planner territory
- Never write to `projects/<slug>/design/` or `handoff/` — that's PD territory
- Never write to `design-system/` — that's DS territory
- If `dev/` directory doesn't exist, create it
