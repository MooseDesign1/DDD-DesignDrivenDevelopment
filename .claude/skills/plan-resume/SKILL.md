---
name: plan-resume
model: opus-4-6
effort: medium
description: >
  Resume a planning session after context reset. Use when the user types /plan:resume,
  says "resume planning", "continue the plan", "pick up where I left off on planning",
  or when the planner dispatcher detects an in-progress session on startup.
---

# Plan Resume

Restore planning context from checkpoint and continue from the last step.

**Effort level: medium.** Be concise and direct.

---

## Step 1 — Load checkpoint

Find active sessions: look for `projects/*/plan/active_session.md`.

If no `active_session.md` exists or all have `status: complete` → tell user:
> "No in-progress planning session found. Use `/plan:status` to see your projects or `/plan:project` to start one."

If multiple projects have in-progress sessions → ask which one to resume.

---

## Step 2 — Show checkpoint summary

Read the `active_session.md` and present:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Resuming: <Project Name>
  Last skill: <plan-project | plan-feature>
  Last step:  <description>
  Feature:    <feature name, if plan-feature>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Ask:
```
question: "Ready to continue?"
options:
  - "Yes — pick up from [last step]"
  - "Jump to a different skill"
  - "Show full plan status first"
```

---

## Step 3 — Route to correct skill

Based on `skill` in `active_session.md`:

| Skill | Route to |
|---|---|
| plan-project | plan-project (at last incomplete step) |
| plan-feature | plan-feature (with feature slug and pass info) |

Pass checkpoint context so the target skill can skip completed steps.

If "Show full plan status" → route to plan-status.
If "Jump to different skill" → ask which, then route.

---

## Rules

- Never restart a skill from scratch on resume — skip to the last incomplete step
- If multiple projects have active sessions → ask which one before loading
- If the checkpoint references a feature that no longer exists in master-plan.md → warn and ask user
