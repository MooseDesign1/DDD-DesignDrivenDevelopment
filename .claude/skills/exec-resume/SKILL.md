---
name: exec-resume
model: sonnet-4-6
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

Find active sessions: look for `projects/*/dev/active_session.md`.

If no `active_session.md` exists or all have `status: complete`:
> "No in-progress build session found. Use `/exec:feature` to start building a feature or `/plan:status` to see what's ready."

If multiple projects have in-progress sessions → use AskUserQuestion to pick one.

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

- **Never restart from scratch on resume** — skip to the last incomplete task
- **Verify branch state** — make sure git state matches checkpoint before continuing
- **If checkpoint references a feature that no longer exists** → warn and ask user
- **If branch has diverged** (someone else pushed changes) → warn before continuing
- **Always re-read reference docs on resume** — they may have been updated between sessions
