---
name: plan-resume
model: opus
effort: high
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

Read `DDD/projects/PROJECTS.md`. Find active sessions: look for `DDD/projects/*/plan/active_session.md`.

**Case A — In-progress session found** (status: in_progress) → continue to Step 2.

**Case B — No session or all complete** → continue to Step 1b.

If multiple in-progress sessions → ask which one to resume.

---

## Step 1b — Intelligent next step detection

No active planning session. Scan all active projects to surface what the planner should do next.

For each project in PROJECTS.md, read in parallel:
- `DDD/projects/<slug>/plan/master-plan.md`
- List files in `DDD/projects/<slug>/handoff/`
- List files in `DDD/projects/<slug>/plan/features/`
- `DDD/projects/<slug>/dev/status.md` (if exists)

Then identify:

**Needs Pass 2 (bundle it)** — `handoff/<feature>-handoff.md` exists but `plan/features/<feature>.md` does not. Design is done; this feature is ready to be turned into an execution bundle.

**Needs Pass 1 (detail it)** — feature appears in master-plan.md as `pending` with no feature file yet. Not yet detailed enough to build.

**Already planned, not started** — feature file exists with `status: ready-for-execution` and doesn't appear in `dev/status.md`. Ready for the executor.

**Blocked on open decisions** — features in master-plan.md tagged `product-decision` with status `pending`.

Present:

```
────────────────────────────────────────────
  No active planning session. Here's what needs the planner:

  NEEDS PASS 2 (design done — bundle for executor):
  • <project> / <feature> — handoff exists, no execution bundle yet
    → /plan:feature <feature>

  NEEDS PASS 1 (not yet detailed):
  • <project> / <feature> — in master plan, no feature file

  READY FOR EXECUTOR (already planned):
  • <project> / <feature> — execution bundle exists

  BLOCKED ON DECISIONS:
  • <project> / <feature> — waiting on: <decision>
────────────────────────────────────────────
```

Use AskUserQuestion:
```
question: "What would you like to plan?"
options:
  - "Bundle <top Pass 2 feature> for the executor"
  - "Detail <top Pass 1 feature>"
  - "Show full plan status — /plan:status"
  - "Start a new project"
```

If user picks a feature → invoke plan-feature for it. Do NOT stall.

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

- **Never stall** — if no active session, scan the plan and surface the next planning action
- Never restart a skill from scratch on resume — skip to the last incomplete step
- If multiple projects have active sessions → ask which one before loading
- If the checkpoint references a feature that no longer exists in master-plan.md → warn and ask user
