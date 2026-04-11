---
name: plan-status
model: haiku
effort: low
description: >
  Show project plan status dashboard. Use when the user types /plan:status, asks
  "what's blocking", "what's ready", "show plan status", "where are we on the plan",
  or wants an overview of phases, gates, and workstream progress.
---

# Plan Status

Show a full project plan overview: phase progress, gate status, blockers, and what's ready.

**Effort level: medium.** Be concise and direct.

---

## Step 1 — Identify active project

Read `DDD/projects/PROJECTS.md`.

If one project with `status: active` → use it.
If multiple active projects → ask:
```
question: "Which project do you want the status for?"
options:
  - "[Project 1]"
  - "[Project 2]"
  - "Show all projects"
```

If no active project → show PROJECTS.md and suggest `/plan:project`.

---

## Step 2 — Load project files

Read:
- `DDD/projects/<slug>/plan/master-plan.md`
- All `DDD/projects/<slug>/plan/features/*.md`
- `DDD/projects/<slug>/design/component-gaps.md` (if exists)
- `DDD/projects/<slug>/dev/status.md` (if exists)

If Jira is configured in master-plan.md → query ticket statuses via Rovo MCP:
```
searchJiraIssuesUsingJql with project key and relevant statuses
```

---

## Step 3 — Auto-detect gate status

For each gate in master-plan.md:

| Gate type | Check | Status |
|---|---|---|
| design → eng-frontend | `DDD/projects/<slug>/handoff/<feature>-handoff.md` exists? | pending → ready |
| design-system gap | `design/component-gaps.md` — all gaps for this feature resolved? | pending → ready |
| product decision | Decision marked in feature plan? | pending → decided |
| eng-backend → eng-frontend | `dev/status.md` shows backend stage complete for this feature? | pending → ready |

Gate status values: `pending` | `in-progress` | `ready` | `complete`

---

## Step 4 — Present dashboard

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Plan Status: <Project Name>
  Phases: <n> | Active: <n> | Complete: <n>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase 1: <Name>                       done
Phase 2: <Name>                       active
  ├── eng-backend: <n>/<n> tasks done
  ├── design: <status>
  ├── eng-frontend: blocked by Gate G1
  └── Gate G1: <status>
Phase 3: <Name>                       backend active
  ├── eng-backend: <n>/<n> tasks done
  ├── design: not started
  └── Gate G2: pending
Phase 4-N: not started

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Blockers
  • Gate G1: Waiting on design handoff for <feature>
  • <Decision>: Blocked — impacts <feature>
  
  Ready for Pass 2 (handoff received)
  • <feature> — run /plan:feature <feature>

  Ready for execution (bundle complete)
  • <feature> — run executor agent

  Ready to start (eng-only, deps met)
  • <feature> tasks in Wave 1

  DS Gaps
  • <n> pending: <component>, <component>
  • <n> resolved

  Open Decisions
  • <decision> — impacts <feature> — needed by <date>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 5 — Suggest next action

Based on current state:

| Situation | Suggest |
|---|---|
| Features not yet detailed | `/plan:feature <feature>` |
| Design needed, not started | `/product-designer` |
| Handoff exists, Pass 2 not done | `/plan:feature <feature>` (for Pass 2) |
| DS gaps pending | `/ds-plan <component>` |
| Feature bundle ready | "Run executor agent" |
| Open decisions blocking | "Resolve: <decision>" |
| All features complete | "Project complete" |

```
What's next: <suggested command> — <why>
```

---

## Rules

- **Gate status is always auto-detected** — read the filesystem, don't trust stale status in plan files
- **If Jira configured, cross-reference** — but local files are source of truth for gate detection
- **Show blockers prominently** — they're the most actionable information
- **Group "ready" items by type** — separate Pass 2 ready, execution ready, and eng-only ready
