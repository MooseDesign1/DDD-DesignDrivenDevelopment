---
name: exec-resume
model: sonnet
effort: medium
description: >
  Resume an in-progress feature build after a context reset. Use when the user types
  /exec:resume, says "resume building", "continue the build", "pick up where I left off
  on development", or when the executor dispatcher detects an in-progress session.
---

# Exec Resume

Restore execution context from checkpoint and continue building from the last task.

**Effort level: medium.** Be concise and direct.

---

## Step 1 — Load checkpoint

Read `DDD/projects/PROJECTS.md` to find active projects.

For each active project, check `DDD/projects/<slug>/dev/active_session.md`.

**Case A — In-progress session found** (status: in_progress):
→ Continue to Step 2.

**Case B — No session or all sessions complete**:
→ Continue to Step 1b (intelligent next step detection).

If multiple projects have in-progress sessions → use AskUserQuestion to pick one.

---

## Step 1b — Intelligent next step detection

No active build session exists. Instead of stopping, look at the plan to find what comes next.

For each active project, read in parallel:
- `DDD/projects/<slug>/plan/master-plan.md`
- `DDD/projects/<slug>/dev/status.md` (if exists)

Then determine the executor's next logical action:

### Check 1 — Partially built features

Read `dev/status.md`. Look for any feature where at least one stage is `complete` but
another is `not-started` or `in-progress`. These are partially built features that can resume.

### Check 2 — Features ready for execution

Read `master-plan.md`. Find features with `status: ready-for-execution` that do NOT appear
in `dev/status.md` yet. These are features queued but not started.

### Check 3 — Gate unblocks

Read master-plan.md Gates section. For each gate with `status: pending`, check if the
gate criterion file now exists (e.g., `handoff/<feature>-handoff.md`). If it does, the
gate has been met — the blocked feature is now unblocked and buildable.

### Check 4 — Features needing Pass 2

Find features in master-plan.md that are `needs-design` and the design handoff exists
(`DDD/projects/<slug>/handoff/<feature>-handoff.md`) but no execution bundle exists yet
(`DDD/projects/<slug>/plan/features/<feature>.md` missing). These need `/plan:feature`
(Pass 2) before they can be built.

### Present findings

After scanning all active projects, present a prioritized status:

```
--------------------------------------------
  No active build session. Here's where things stand:

  READY TO BUILD:
  • [project] / <feature> — ready-for-execution, not started
  • [project] / <feature> — backend complete, frontend queued

  UNBLOCKED (gate just met):
  • [project] / <feature> — design handoff found, ready to build

  NEEDS PASS 2 FIRST:
  • [project] / <feature> — handoff exists, execution bundle missing
    → run /plan:feature <feature> first

  WAITING ON DESIGN:
  • [project] / <feature> — no handoff yet
--------------------------------------------
```

Use AskUserQuestion:
```
question: "What would you like to do?"
options:
  - "Build <top ready feature> — start /exec:feature"
  - "Run Pass 2 on <feature needing bundle> first"
  - "Show full project status — /plan:status"
  - "I want to build a different feature"
```

If user selects a feature to build → invoke exec-feature for that feature.
If user selects Pass 2 → tell user to run `/plan:feature <feature>`.

Do NOT stall — always surface the next actionable step.

---

## Step 2 — Show checkpoint summary

Read the `active_session.md` and `dev/status.md`. Present:

```
--------------------------------------------
  Resuming: <Project Name> / <Feature Name>
  Branch: exec/<feature-slug>
  
  Last skill: exec-feature
  Current stage: <ds-gaps | backend | frontend>
  Current task: <task title> (<n> of <m>)
  
  Completed:
    • <completed items>
  
  Remaining:
    • <remaining items>
--------------------------------------------
```

Use AskUserQuestion:
```
question: "Ready to continue?"
options:
  - "Yes — pick up from <current task>"
  - "Skip to next stage"
  - "Show full status first"
  - "Start this stage over"
```

---

## Step 3 — Verify branch state

Check that the git branch exists and is checked out:
```bash
git branch --show-current
```

If not on the correct branch → switch to it:
```bash
git checkout exec/<feature-slug>
```

Verify the commits match what active_session.md says was completed. If there's a mismatch, warn:
> "Branch state doesn't match checkpoint. <n> commits expected, <m> found. Continue anyway?"

---

## Step 4 — Route to exec-feature

Pass checkpoint context to exec-feature so it can skip completed stages and tasks:
- Skip stages marked complete in status.md
- Within the current stage, skip tasks already committed
- Resume from the current task index

If "Show full status" → read and present dev/status.md, then re-ask.
If "Start stage over" → warn about existing commits, then re-run the current stage.

---

## Rules

- **Never stall** — if no active session exists, scan the plan and surface the next action
- **Never restart from scratch on resume** — skip to the last incomplete task
- **Verify branch state** — make sure git state matches checkpoint before continuing
- **If checkpoint references a feature that no longer exists** → warn and ask user
- **If branch has diverged** (someone else pushed changes) → warn before continuing
- **Always re-read reference docs on resume** — they may have been updated between sessions
- **Gate detection is proactive** — always check if handoff files exist that weren't there before; a met gate is an actionable signal
- **Surface Pass 2 needs explicitly** — if a handoff exists but no execution bundle, name the exact command to run
