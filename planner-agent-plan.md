# Planner Agent Framework — Implementation Plan

> Status: Ready to implement
> Date: 2026-04-07
> Scope: 5 skill files for a generic 0-to-1 product development planner

---

## What This Is

A planning framework that takes any product from brief to launch. It orchestrates across all workstreams — product decisions, design, engineering, and infrastructure. The planner doesn't DO the work — it plans, sequences, tracks, and identifies what's blocking.

It sits alongside the existing pd-* (product design) and ds-* (design system) agents.

---

## Key Design Decisions

1. **Local-first** — plan always lives as markdown files. Jira is optional sync.
2. **Two-pass epic planning** — for epics with design work, Pass 1 plans backend fully and defines design scope. Pass 2 (after design handoff) completes frontend plan AND flags backend revisions that design surfaced.
3. **Full workstream model** — infra, eng-backend, eng-frontend, design, design-system, product-decision. No GTM for now.
4. **Design handoff doc is an input** — `pd-handoff` produces a spec doc. `plan:epic` reads it to complete Pass 2.
5. **Design can change backend** — Pass 2 isn't just frontend. Design may reveal new API endpoints, schema changes, or different data shapes. The epic plan must capture backend revisions alongside the frontend plan.

---

## Skills to Create

```
.claude/skills/
├── plan-project/SKILL.md      # Master planner — brief → phases → local plan (+ optional Jira)
├── plan-epic/SKILL.md         # Epic-level planner (two-pass for design epics)
├── plan-status/SKILL.md       # Status dashboard across all workstreams
├── plan-resume/SKILL.md       # Resume after context reset
└── plan-write-memory/SKILL.md # Internal — persist plan state
```

## Memory Structure

```
projects/<slug>/plan/
├── master-plan.md          # Phases, tracks, gates, dependency graph
├── active_session.md       # Planning session checkpoint
└── epics/
    ├── <epic-slug>.md      # Detailed epic plan (one per epic)
    └── ...
```

---

## Skill 1: `/plan:project` — Master Project Planner

**Trigger:** `/plan:project`, "plan the project", "break this down", "create a roadmap"

### Flow

**Step 1 — Load context**
- Read `projects/PROJECTS.md` (existing projects)
- Read `projects/<slug>/brief.md` if exists
- Read `projects/<slug>/plan/master-plan.md` if replanning

**Step 2 — Brief intake**
Same pattern as pd-new-project. Ask:
```
"Do you have a product brief ready?"
  - "Yes — paste, URL, Confluence page, or file path"
  - "No — help me write one"
```
If Confluence → use Rovo MCP tools to read pages.
If no brief → interview: product, users, problem, capabilities, tech stack, constraints.

**Step 3 — Feature extraction**
From the brief, extract a flat list of capabilities. Present for confirmation:
```
I identified these capabilities:
1. Auth & org management
2. Wiki CRUD + taxonomy
3. Classification engine
...
Does this list look right? Anything to add or remove?
```

**Step 4 — Classify each feature into workstreams**

| Workstream | Description | Examples |
|------------|-------------|---------|
| `infra` | Infrastructure, deployment, CI/CD | Supabase setup, Vercel, Railway |
| `eng-backend` | Backend: DB, APIs, services, jobs | Schemas, API routes, workers |
| `eng-frontend` | Frontend build from designs | React components wired to APIs |
| `design` | UI/UX design (pd agent) | Auth screens, wiki UI, dashboards |
| `design-system` | New DS components needed | Custom components not in library |
| `product` | Product decisions still needed | Pricing, naming, scope calls |

A capability can span multiple workstreams. Present classification for confirmation.

**Step 5 — Group into epics**
Group related capabilities into epics. Each epic = one phase. Present for confirmation.

**Step 6 — Sequence epics and map dependencies**
For each epic, determine:
- What other epics it depends on
- Which workstreams are involved
- Whether it has parallel tracks (backend starts while design works)

Build dependency graph.

**Step 7 — Map ALL handoff gates**
For every epic that spans workstreams, define gates:

```markdown
### Gate G1: Auth Design → Auth Frontend
- **Type:** design → eng-frontend
- **Epic:** Phase 2 (Auth)
- **Blocked work:** Auth UI build (eng-frontend)
- **Unblocked parallel work:** Auth API, middleware (eng-backend)
- **Handoff input:** pd-handoff doc at projects/<slug>/handoff/<slug>-handoff.md
- **Gate criteria:**
  - [ ] Figma screens finalized and annotated
  - [ ] pd-handoff doc produced
  - [ ] Component gaps resolved or documented
```

Gate types:
- **design → eng-frontend:** Design must finish before UI build
- **design → eng-backend (revision):** Design may surface backend changes
- **product → design:** Product decision needed before design can start
- **product → eng:** Decision needed before engineering can proceed
- **eng-backend → eng-frontend:** API must exist before UI can wire to it
- **eng-backend → eng-backend:** Service A must exist before Service B

**Step 8 — Generate master plan document**
Write `projects/<slug>/plan/master-plan.md` (format below).

**Step 9 — Jira sync (optional)**
Ask: "Want me to sync this to Jira?"
- If yes → create epics + tasks via Rovo MCP, record keys in master-plan.md
- If no → plan lives locally only, can sync later

**Step 10 — Checkpoint**
Write `projects/<slug>/plan/active_session.md`. Invoke plan-write-memory.

### Master Plan Document Format

```markdown
# Master Plan: <Project Name>

> Created: <date>
> Last updated: <date>
> Status: planning | active | complete
> Jira: <project key> | none

## Overview
<2-3 sentence summary>

## Workstreams Active
- [x] infra
- [x] eng-backend
- [x] eng-frontend
- [x] design
- [ ] design-system
- [x] product

## Phases

### Phase 1: <Epic Name>
- **Jira:** <key or "local only">
- **Workstreams:** infra, eng-backend
- **Depends on:** nothing
- **Parallel tracks:** none (single workstream)
- **Tickets:**
  - [ ] <ticket title> [eng-only]
  - [ ] <ticket title> [eng-only]

### Phase 2: <Epic Name>
- **Jira:** <key or "local only">
- **Workstreams:** eng-backend, design → eng-frontend
- **Depends on:** Phase 1
- **Parallel tracks:**
  - Track A (eng-backend): starts immediately — DB schema, API routes
  - Track B (design): starts when brief is ready — auth screens, onboarding
  - Track C (eng-frontend): starts after Gate G1 — wire UI to APIs
- **Tickets:**
  - [ ] <ticket> [eng-only] — Track A
  - [ ] <ticket> [needs-design] — Track B → C
  - [ ] <ticket> [needs-design] — Track B → C
- **Gate:** G1

## Dependency Graph
<ASCII diagram>

## Gates

### Gate G1: <Name>
- **Type:** design → eng-frontend
- **Epic:** Phase 2
- **Blocked:** <ticket list>
- **Parallel:** <ticket list>
- **Handoff input:** projects/<slug>/handoff/<epic>-handoff.md
- **Criteria:**
  - [ ] <criterion>
- **Status:** pending

## Open Decisions
| Decision | Impacts | Needed by | Status |
|----------|---------|-----------|--------|
```

---

## Skill 2: `/plan:epic` — Epic-Level Planner

**Trigger:** `/plan:epic`, "plan this epic", "detail phase 2", "break down the auth epic"

### The Two-Pass Model

Epics with design work are planned in **two passes**:

**Pass 1 (before design):**
- Fully plan all `eng-only` / `infra` / `eng-backend` tickets
- For `needs-design` tickets: define what design must answer, but DON'T plan the frontend implementation
- Mark frontend implementation as `awaiting-design-handoff`

**Pass 2 (after design handoff):**
- Read the pd-handoff doc (`projects/<slug>/handoff/<epic>-handoff.md`)
- Plan the frontend implementation from the handoff: components, wiring, states, interactions
- **Diff the backend:** compare what was built in Pass 1 against what design now requires. Flag backend revisions — new endpoints, schema changes, different data shapes, additional states
- Update the epic plan with full details for both frontend AND backend revisions

For pure `eng-only` epics, there's only one pass — everything is planned upfront.

### Flow

**Step 1 — Load context**
- Read `projects/<slug>/plan/master-plan.md`
- If no master plan → "Run `/plan:project` first."

**Step 2 — Select epic**
If not specified, show epics and ask. Check if this epic has been planned before.

**Step 3 — Determine pass**
Check if epic has `needs-design` tickets:
- If no → single pass, plan everything
- If yes → check if handoff doc exists at `projects/<slug>/handoff/`
  - No handoff doc → **Pass 1** (plan backend, mark frontend as awaiting)
  - Handoff doc exists → **Pass 2** (read handoff, complete frontend plan, flag backend revisions)

**Step 4a — Pass 1: Plan backend + define design scope**

For each `eng-only` / `infra` / `eng-backend` ticket:
```markdown
### <Ticket Title>
**Workstream:** eng-backend
**Approach:** <technical approach — what to build, how>
**Acceptance criteria:**
- [ ] <specific, testable>
**Depends on:** <other tickets>
**Complexity:** S | M | L
```

For each `needs-design` ticket:
```markdown
### <Ticket Title>
**Workstream:** design → eng-frontend
**Plan status:** pass-1 (awaiting design handoff)

#### What design must answer
- <question 1>
- <question 2>

#### Parallel backend work
- <what eng can build now that this UI will need>

#### Frontend implementation
Awaiting design handoff doc.
Re-run `/plan:epic` after design delivers to complete this section.

#### Gate criteria
- [ ] <handoff criterion>
```

For `product-decision` tickets:
```markdown
### Decide: <Decision>
**Type:** product-decision
**Options:** <known options>
**Impacts:** <what tickets are blocked>
**Needed by:** <when>
**Who decides:** <person>
```

**Step 4b — Pass 2: Complete plan from handoff doc**

Read the pd-handoff doc. For each `needs-design` ticket that was `awaiting-design-handoff`:

```markdown
### <Ticket Title>
**Workstream:** design → eng-frontend
**Plan status:** pass-2 (design handoff received)
**Handoff doc:** projects/<slug>/handoff/<epic>-handoff.md

#### Design delivered
- Screens: <list from handoff>
- Components: <from component map>
- States: <from states table>
- Interactions: <from logic & behavior>

#### Frontend implementation
**Build from handoff:**
1. <component 1> — use <DS component or build custom>
2. <component 2> — wire to <API endpoint>
3. <state management> — <approach>
4. <real-time> — connect subscription

**Acceptance criteria:**
- [ ] <from handoff ACs>
- [ ] Matches Figma design
- [ ] All states implemented (loading, error, empty, success)

**Complexity:** <now estimable>
```

Then diff against Pass 1 backend plan:

```markdown
#### Backend revisions (surfaced by design)

Compare the handoff doc's requirements against the Pass 1 backend plan.
For each difference, log a revision:

| What changed | Pass 1 assumption | Design requires | Impact |
|-------------|-------------------|-----------------|--------|
| <endpoint/schema/field> | <what was planned> | <what design needs> | <new ticket or modify existing> |

If no revisions needed → note "No backend changes required — Pass 1 plan holds."

For each revision:
- If minor (add a field, adjust response shape) → update the existing ticket's plan
- If significant (new endpoint, new table, new job) → create a new ticket
- Flag any revision that invalidates already-built backend work
```

**Step 5 — Sequence within epic**
Order all tickets by dependency:
```
Immediate: <eng-only tickets with no deps>
After deps: <eng-only tickets with deps>
After design: <needs-design tickets, post-handoff>
Backend revisions: <revision tickets from Pass 2, if any>
```

**Step 6 — Save epic plan**
Write to `projects/<slug>/plan/epics/<epic-slug>.md`
Update master-plan.md.
Invoke plan-write-memory.

**Step 7 — Jira sync (optional)**
If Jira configured, ask: "Update Jira tickets with these details?"
If backend revisions created new tickets → create them in Jira too.

---

## Skill 3: `/plan:status` — Status Dashboard

**Trigger:** `/plan:status`, "show plan status", "what's blocking", "what's ready"

### Flow

**Step 1 — Load context**
- Read `projects/<slug>/plan/master-plan.md`
- Read all `projects/<slug>/plan/epics/*.md`
- If Jira configured → query ticket statuses via Rovo MCP
- If local only → read status from plan files

**Step 2 — Cross-reference gates**
For each gate:
- Check if handoff doc exists (design → eng-frontend gates)
- Check ticket statuses (local or Jira)
- Determine gate status: `pending` | `design-in-progress` | `ready` | `complete`

**Step 3 — Present dashboard**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Plan Status: <Project Name>
  Phases: 8 | Active: 2 | Complete: 1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase 1: Foundation        done
Phase 2: Auth              active
  |-- eng-backend: 1/1 done
  |-- design: in progress (2/3 screens)
  |-- eng-frontend: blocked by Gate G1
  |-- Gate G1: design-in-progress
Phase 3: Wiki              backend active
  |-- eng-backend: 2/4 done
  |-- design: not started
  |-- Gate G2: pending
Phase 4-7: not started

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Blockers
  - Gate G1: Waiting on design handoff
  - KAN-24: Blocked by decision (embedding model)

  Ready to pick up (eng-only, deps met)
  - KAN-25 (raw_sources schema)
  - KAN-31 (vault schema)
  - KAN-38 (MCP scaffold)

  Ready for Pass 2 planning (handoff received)
  - (none yet)

  Backend revisions pending
  - (none yet)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Skill 4: `/plan:resume` — Resume Planning

**Trigger:** `/plan:resume`, "resume planning", "continue the plan"

Same pattern as pd-resume:
1. Read `projects/<slug>/plan/active_session.md`
2. Show checkpoint summary (which skill, which step, which epic)
3. Ask: "Ready to continue?"
4. Route to correct skill at correct step

---

## Skill 5: `plan-write-memory` — Internal

Same pattern as pd-write-memory:
1. Determine what changed (master-plan.md, epic plans, active_session.md)
2. Write only changed files
3. Update PROJECTS.md with plan phase
4. Report what was written

---

## How It All Fits Together

```
Brief (Confluence, paste, URL)
  |
  v
/plan:project --> master-plan.md (phases, gates, dependency graph)
  |
  v
/plan:epic (Pass 1) --> epic plan: backend fully detailed, frontend awaiting design
  |
  v
Engineer builds backend (eng-only tickets)         <-- in parallel
Designer runs pd workflow (discover-->handoff)      <-- in parallel
  |
  v
pd-handoff produces handoff doc
  |
  v
/plan:epic (Pass 2) --> reads handoff doc, completes frontend plan,
                        diffs backend and flags revisions
  |
  v
Engineer builds frontend from plan + handoff doc
Engineer addresses backend revisions (if any)
  |
  v
/plan:status --> tracks progress, surfaces blockers, identifies ready work
```

---

## Edge Cases

**Existing Jira tickets:** Discovered via JQL search, mapped to epics, never duplicated.

**No brief:** Falls back to interview pattern (same as pd-new-project).

**Design changes the backend:** Pass 2 explicitly diffs the handoff doc against Pass 1 backend plan. Revisions are logged as a table. Minor changes update existing tickets. Significant changes create new tickets.

**Re-running plan:epic:** If an epic was already planned, Pass 1 is skipped (already done). If handoff doc now exists, Pass 2 runs. If Pass 2 was already done and you re-run, it re-diffs (design may have iterated).

**Product decisions unresolved:** Tickets blocked by decisions are flagged in plan:status. The decision ticket tracks options, impacts, and deadline.

**Epic with no design:** Single-pass planning. Everything is detailed upfront. No gates, no Pass 2.

---

## Files to Create

| # | File | Type |
|---|------|------|
| 1 | `.claude/skills/plan-project/SKILL.md` | User-facing |
| 2 | `.claude/skills/plan-epic/SKILL.md` | User-facing |
| 3 | `.claude/skills/plan-status/SKILL.md` | User-facing |
| 4 | `.claude/skills/plan-resume/SKILL.md` | User-facing |
| 5 | `.claude/skills/plan-write-memory/SKILL.md` | Internal |

---

## What This Plan Does NOT Cover (Deferred)

- GTM workstream (excluded per user decision, add later)
- Automated Jira status sync (reading Jira status back into local plan files)
- Sprint/timeline estimation
- Resource allocation (who works on what)
- Integration with CI/CD or deployment tracking
