---
name: exec-feature
model: sonnet-4-6
effort: medium
description: >
  Core executor orchestrator. Builds a feature from its execution bundle stage by stage:
  DS Gaps → Backend → Frontend, with architect planning, verifier checks, and human
  checkpoints between each stage. Use when the user types /exec:feature, says "build
  this feature", "execute the auth feature", "start building [feature]", or wants to
  build a planned feature.
---

# Exec Feature

Orchestrate building a complete feature from its execution bundle.

**Effort level: medium.** Orchestrate and delegate — never write code directly.

---

## Step 1 — Load context and select feature

Read `projects/PROJECTS.md`. Identify the active project.

If multiple active projects → use AskUserQuestion to pick one.

Read `projects/<slug>/plan/master-plan.md`. List features with `status: ready-for-execution`.

If the user specified a feature → use it.
If not → use AskUserQuestion:
```
question: "Which feature do you want to build?"
options:
  - "<feature 1> — ready for execution"
  - "<feature 2> — ready for execution"
  - "<feature 3> — not yet ready (needs Pass 2)"
```

Load the feature bundle from `projects/<slug>/plan/features/<feature-slug>.md`.
Verify it has `status: ready-for-execution`. If not → tell user to run `/plan:feature` first.

---

## Step 2 — Determine starting point

Use AskUserQuestion:
```
question: "Where are you on <feature name>?"
options:
  - "Starting fresh — no code yet"
  - "DS gaps already built — skip to backend"
  - "Backend is done — skip to frontend"
  - "Everything built — just verify"
  - "Codebase not mapped yet — run mapper first"
```

### If "Codebase not mapped yet"
Invoke exec-code-mapper. After completion, return to this step and re-ask
(without the mapper option).

### If "Starting fresh"
→ Start from Stage 0 (reference docs check).

### If "DS gaps already built"
→ Skip Stage 1, start from Stage 2 (Backend).

### If "Backend is done"
→ Skip Stages 1 and 2, start from Stage 3 (Frontend).

### If "Everything built — just verify"
→ Skip to Stage 4 (Final verification).

---

## Step 3 — Reference docs check

Check if `projects/<slug>/dev/architecture.md` exists.

- **Exists** → read it, confirm it's reasonably current
- **Missing** → invoke exec-code-mapper to generate reference docs before proceeding

Also read:
- `dev/api-map.md` (if exists)
- `dev/component-map.md` (if exists)
- `dev/db-schema.md` (if exists)

---

## Step 4 — Create git branch

Create the execution branch:
```bash
git checkout -b exec/<feature-slug>
```

If branch already exists (resuming), switch to it:
```bash
git checkout exec/<feature-slug>
```

---

## Stage 1 — DS Gaps

**Skip if:** feature bundle has no DS Gap Tasks section, or user said gaps are built.

Read the DS Gap Tasks from the feature bundle. For each gap:

Use AskUserQuestion:
```
question: "DS Gap: <ComponentName> — Is this component already built?"
options:
  - "Yes — it's built, skip it"
  - "No — I'll build it now with /ds-build"
  - "No — skip it for now, use placeholder"
```

- **"Yes"** → mark as complete, continue
- **"Build now"** → tell user to run `/ds-build <ComponentName>`. Pause and wait. When user returns, continue.
- **"Skip"** → mark as skipped with placeholder note, continue

After all gaps are addressed:

### CHECKPOINT: DS Gaps

```
--------------------------------------------
  CHECKPOINT: DS Gaps Complete
  
  Built: <n>  |  Skipped: <n>  |  Already done: <n>
  
  Verify: Are all needed components ready?
--------------------------------------------
```

Use AskUserQuestion:
```
question: "DS gaps addressed. Ready to proceed to backend?"
options:
  - "Yes — continue to backend"
  - "Wait — I need to build more components first"
  - "Go back — a component needs changes"
```

Update `dev/status.md` via exec-write-memory: DS Gaps → complete.

---

## Stage 2 — Backend

Extract all backend tasks from the feature bundle (including any backend revisions from Pass 2).

### 2a — Architecture planning

Invoke exec-architect with:
- The feature bundle
- Stage: `backend`
- All backend tasks

Review the architect's output. If flags exist (schema changes, no precedent, ambiguity):

Use AskUserQuestion:
```
question: "Architect flagged <n> items for backend. Review before building?"
options:
  - "Show me the flags"
  - "Proceed — I trust the architect's decisions"
```

If user wants to review → present flags, let them decide.

### 2b — Task execution loop (wave-parallel)

Process the architect's waves in order. Within each wave:

**Single-task wave** → invoke exec-backend with:
- The task block
- The architect context for this task
- Project and feature slugs

**Multi-task wave** → invoke exec-backend simultaneously for all tasks in the wave.
Each runs as an independent subagent with its own context window.
Spawn all tasks in the wave in the same response — do not wait for one before starting others.
Collect all results before moving to the next wave.

After each wave (all tasks in that wave complete):
1. Receive task results (files written, commit hash, AC status)
2. Update active_session.md checkpoint via exec-write-memory

### 2c — Stage verification

After all backend tasks complete, invoke exec-verifier with:
- Stage: `backend`
- All task results
- Feature bundle (for ACs)
- Originating agent: `exec-backend`

**If PASS** → proceed to checkpoint.
**If BLOCKED** → present critical issues to user:

Use AskUserQuestion:
```
question: "Verifier found <n> critical issues in backend. How to proceed?"
options:
  - "Show me the issues — I'll fix manually"
  - "Try auto-fix on all issues"
  - "Skip verification — proceed anyway"
```

### CHECKPOINT: Backend

```
--------------------------------------------
  CHECKPOINT: Backend Stage Complete
  
  Tasks: <n>/<n> complete
  Commits: <n>
  Verification: <PASS / n issues>
  
  New routes: <list>
  Schema changes: <list or "none">
--------------------------------------------
```

Use AskUserQuestion:
```
question: "Backend complete. Verify and continue?"
options:
  - "Looks good — continue to frontend"
  - "I need to test these endpoints first"
  - "Something's wrong — let me review"
```

Update `dev/status.md` via exec-write-memory: Backend → complete.

---

## Stage 3 — Frontend

Extract all frontend tasks from the feature bundle.

### 3a — Architecture planning

Invoke exec-architect with:
- The feature bundle (including design context section)
- Stage: `frontend`
- All frontend tasks

### 3b — Task execution loop (wave-parallel)

Process the architect's waves in order. Within each wave:

**Single-task wave** → invoke exec-frontend with:
- The task block
- The architect context for this task
- The design context from the feature bundle
- Project and feature slugs

**Multi-task wave** → invoke exec-frontend simultaneously for all tasks in the wave.
Each runs as an independent subagent with its own context window.
Spawn all tasks in the wave in the same response — do not wait for one before starting others.
Collect all results before moving to the next wave.

After each wave (all tasks in that wave complete):
1. Receive task results
2. Update active_session.md checkpoint via exec-write-memory

### 3c — Stage verification

Invoke exec-verifier with:
- Stage: `frontend`
- All task results
- Feature bundle
- Originating agent: `exec-frontend`

Handle PASS/BLOCKED same as backend stage.

### CHECKPOINT: Frontend

```
--------------------------------------------
  CHECKPOINT: Frontend Stage Complete
  
  Tasks: <n>/<n> complete
  Commits: <n>
  Verification: <PASS / n issues>
  
  Components created: <list>
  DS gaps flagged: <list or "none">
--------------------------------------------
```

Use AskUserQuestion:
```
question: "Frontend complete. Verify UI matches design?"
options:
  - "Looks good — finalize"
  - "I need to compare with Figma first"
  - "Something's wrong — let me review"
```

Update `dev/status.md` via exec-write-memory: Frontend → complete.

---

## Stage 4 — Final verification

Read the feature bundle's must-haves (from the Verification section).

Present:
```
--------------------------------------------
  FINAL VERIFICATION: <Feature Name>

  Must-haves:
  - [ ] <must-have 1>
  - [ ] <must-have 2>
  - [ ] <must-have n>
  
  These require human verification.
  Test the feature and check off each item.
--------------------------------------------
```

Use AskUserQuestion:
```
question: "Have you verified the must-haves?"
options:
  - "All verified — feature is complete"
  - "Issues found — need changes"
  - "Skip for now — mark as needs-verification"
```

---

## Step 5 — Finalize

Update `dev/status.md` via exec-write-memory: Feature → complete.

Present:
```
--------------------------------------------
  Feature Complete: <Feature Name>
  Branch: exec/<feature-slug>
  
  Stage 1 (DS Gaps): <complete/skipped>
  Stage 2 (Backend): <n> tasks, <n> commits
  Stage 3 (Frontend): <n> tasks, <n> commits
  Verification: <passed/needs-verification>
  
  Total commits: <n>
  Files changed: <n>
--------------------------------------------

  Next steps:
  • Review the branch and create a PR
  • Run /plan:status to see overall project progress
  • Run /exec:feature for the next feature
--------------------------------------------
```

---

## Rules

- **Never write code directly** — always delegate to exec-backend or exec-frontend
- **Always invoke exec-architect before each stage** — architecture decisions first, then code
- **Always invoke exec-verifier after each stage** — quality gate is non-negotiable
- **Human checkpoints between every stage** — never auto-proceed without user confirmation
- **Flexible entry** — user can skip stages they've already completed
- **One feature at a time** — finish or pause before starting another
- **DS gaps are opt-in** — always ask if components are already built
- **Update checkpoint after every task** — active_session.md must always reflect current state
- **Git branch per feature** — all work on `exec/<feature-slug>`
- **If context is above 50% used** — recommend `/clear` and `/exec:resume` before continuing
