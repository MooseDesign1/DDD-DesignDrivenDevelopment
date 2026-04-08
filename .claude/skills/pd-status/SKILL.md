---
name: pd-status
description: >
  Show the current product design project status dashboard. Use when the user types
  /pd:status, asks "where are we", "what's done", "show me the project", "progress",
  or wants an overview of the active project's phase, screens, and blockers.
---

# Project Status

Show a full project overview: phase, screen inventory, gaps, and what's next.

---

## Step 1 — Identify active project

Read `projects/PROJECTS.md`.

If one project with `status: in_progress` → use it.
If multiple in-progress projects → ask:
```
question: "Which project do you want the status for?"
options:
  - "[Project 1 name]"
  - "[Project 2 name]"
  - "Show all projects"
```

If no active project → show PROJECTS.md summary and suggest `/pd:new-project`.

---

## Step 2 — Load project files

Read:
- `projects/<slug>/brief.md`
- `projects/<slug>/design/screen-inventory.md`
- `projects/<slug>/design/component-gaps.md`
- `projects/<slug>/design/active_session.md`
- `projects/<slug>/design/directions.md`

---

## Step 3 — Generate status report

Present:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  <Project Name>
  Phase: <DISCOVER | DEFINE | CONCEPT | DESIGN | ANNOTATE | HANDOFF>
  Started: <date>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Phase Progress
  ◉ Discover    [complete | in progress | not started]
  ◉ Define      [complete | in progress | not started]
  ◉ Concept     [complete | in progress | not started]
  ◉ Design      [complete | in progress | not started]
  ◉ Annotate    [complete | in progress | not started]
  ◉ Handoff     [complete | in progress | not started]

## Screens
  Total:        <n>
  Designed:     <n>
  Annotated:    <n>
  Remaining:    <n>

  <if remaining screens exist, list them>
  Not started: <screen1>, <screen2>, ...

## Flows
  <flow name>   <n>/<n> screens complete
  <flow name>   <n>/<n> screens complete

## Component Gaps
  <n> total
  <n> resolved
  <n> pending: <component1>, <component2>

## Concept Directions
  <n> items concepted · <n> directions locked

## Active Session Checkpoint
  <last phase + step from active_session.md>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 4 — What's next guidance

Based on current phase and status, suggest the right next command:

| Current Phase | Status | Suggest |
|---|---|---|
| none / init | — | `/pd:discover` |
| DISCOVER | complete | `/pd:define` |
| DEFINE | complete | `/pd:concept` |
| CONCEPT | complete | `/pd:design` |
| DESIGN | in progress | `/pd:design` (resume) |
| DESIGN | complete | `/pd:annotate` |
| ANNOTATE | complete | `/pd:handoff` |
| HANDOFF | complete | "Project complete 🎉" |

```
**What's next:** /pd:<command> — <description>
```
