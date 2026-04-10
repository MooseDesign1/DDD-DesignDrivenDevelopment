---
name: plan-project
model: opus
effort: high
description: >
  Master project planner. Use when the user types /plan:project, says "plan the project",
  "I have a brief", "break this down", "create a roadmap", or wants to initialize a project
  plan with phases, features, gates, and workstream classification.
  Creates master-plan.md with the full project breakdown.
---

# Plan Project

Take a product brief and produce a phased master plan with features, gates, and dependency graph.

**Effort level: medium.** Be concise and direct — plan and delegate, don't over-analyze.

---

## Step 1 — Load context

Read `DDD/projects/PROJECTS.md` if it exists. Note any existing projects.
If replanning an existing project, read `DDD/projects/<slug>/plan/master-plan.md`.

---

## Step 2 — Brief intake

Use AskUserQuestion:
```
question: "Do you have a product brief or PRD ready?"
options:
  - "Yes — I have a brief or PRD"
  - "No — help me write one"
```

### If YES — ingest brief

Ask freeform:
> "Paste the link(s) — one per line. I support Notion, Confluence, Google Docs, Figma, Jira, or any URL. You can share multiple documents."

Also scan reactively — if the user already pasted URLs earlier, treat those as provided.

Fetch all URLs in parallel. Also handle:
- **Pasted content** → use as-is
- **Confluence** → use Rovo MCP tools to read pages
- **Figma link** → use figma_get_metadata and figma_get_design_context
- **Jira** → use Rovo MCP to read epics/tickets
- **Local file path** → read the file

**Preserve, don't summarize.** Extract and organize content into brief.md.

### If NO — interview

Ask one at a time:
1. **What is this product or feature?** — name, one-line pitch
2. **Who is the primary user?** — role, context
3. **What problem are you solving?** — core pain or unmet need
4. **What are the main things users need to do?** — key capabilities/flows
5. **What platforms?** — web, iOS, Android, all?
6. **Tech stack?** — framework, database, infrastructure
7. **Any constraints?** — existing design system, deadline, brand rules
8. **How will you know it's successful?** — metric, behavior, or outcome

Compile into brief format, confirm with user.

---

## Step 3 — Project slug and naming

Ask:
```
question: "What should we call this project?"
options:
  - "[Suggested: <slugified-product-name>]"
  - "Let me type a different name"
```

Slugify: lowercase, hyphens, no spaces.

---

## Step 4 — Feature extraction

From the brief, extract a flat list of capabilities. Present for confirmation:

```
I identified these capabilities:
1. Auth & org management
2. Wiki CRUD + taxonomy
3. Classification engine
4. Dashboard & analytics
...

Does this list look right? Anything to add or remove?
```

---

## Step 5 — Workstream classification

For each capability, tag which workstreams are involved:

| Workstream | Description |
|---|---|
| `infra` | Infrastructure, deployment, CI/CD, environment setup |
| `eng-backend` | Database, APIs, services, jobs, business logic |
| `eng-frontend` | Frontend build from designs (after handoff) |
| `design` | UI/UX design (pd agent) |
| `design-system` | New DS components needed |
| `product-decision` | Product decisions still needed before work can start |

A capability can span multiple workstreams. Present classification for confirmation.

---

## Step 6 — Group into phases

Group related capabilities into phases. Each phase is a milestone. Present:

```
Phase 1: Foundation
  Features: project setup, CI/CD, database schema
  Workstreams: infra, eng-backend

Phase 2: Auth & Onboarding
  Features: login flow, org setup, role management
  Workstreams: eng-backend, design → eng-frontend

Phase 3: Core Product
  Features: wiki CRUD, taxonomy, search
  Workstreams: eng-backend, design → eng-frontend, design-system
```

Confirm with user.

---

## Step 7 — Sequence and map dependencies

For each phase, determine:
- What phases it depends on
- Which features can start in parallel
- Where design work creates gates (backend can start, frontend waits for handoff)

Build dependency graph. Present as ASCII diagram:

```
Phase 1 ──→ Phase 2 ──→ Phase 3 ──→ Phase 4
                ↘                      ↗
                 Phase 5 (parallel) ──┘
```

---

## Step 8 — Map ALL handoff gates

For every feature that spans workstreams, define gates:

```markdown
### Gate G1: Auth Design → Auth Frontend
- **Type:** design → eng-frontend
- **Phase:** 2
- **Feature:** Login flow
- **Blocked work:** Login UI build (eng-frontend)
- **Parallel work:** Auth API, middleware (eng-backend)
- **Handoff input:** DDD/projects/<slug>/handoff/auth-login-handoff.md
- **Gate criteria:**
  - [ ] Figma screens finalized and annotated
  - [ ] pd-handoff doc produced
  - [ ] Component gaps resolved or documented
- **Status:** pending
```

Gate types:
- **design → eng-frontend:** Design must finish before UI build
- **design → eng-backend (revision):** Design may surface backend changes
- **product → design:** Product decision needed before design starts
- **product → eng:** Decision needed before engineering proceeds
- **eng-backend → eng-frontend:** API must exist before UI wires to it

---

## Step 9 — Goal-backward validation

For each phase, derive must-haves from the end state:

> "What must be TRUE when Phase 2 is complete?"
> - User can log in with valid credentials
> - Invalid credentials are rejected
> - Org setup wizard is functional
> - Role-based access works

Validate that the features and their tasks cover all must-haves. Flag any gap.

---

## Step 10 — Generate master plan

Write `DDD/projects/<slug>/plan/master-plan.md`:

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
- [x] product-decision

## Phases

### Phase 1: <Name>
- **Workstreams:** infra, eng-backend
- **Depends on:** nothing
- **Features:**
  - [ ] <feature> [eng-only]
  - [ ] <feature> [eng-only]

### Phase 2: <Name>
- **Workstreams:** eng-backend, design → eng-frontend
- **Depends on:** Phase 1
- **Parallel tracks:**
  - Track A (eng-backend): starts immediately
  - Track B (design): starts when brief is ready
  - Track C (eng-frontend): starts after Gate G1
- **Features:**
  - [ ] <feature> [eng-only] — Track A
  - [ ] <feature> [needs-design] — Track B → C
- **Gate:** G1

## Dependency Graph
<ASCII diagram>

## Gates

### Gate G1: <Name>
- **Type:** design → eng-frontend
- **Phase:** 2
- **Feature:** <feature>
- **Blocked:** <feature list>
- **Parallel:** <feature list>
- **Handoff input:** DDD/projects/<slug>/handoff/<feature>-handoff.md
- **Criteria:**
  - [ ] <criterion>
- **Status:** pending

## Open Decisions
| Decision | Impacts | Needed by | Status |
|----------|---------|-----------|--------|
```

---

## Step 10b — Spawn task-verifier

After writing master-plan.md, spawn task-verifier as a subagent with:
- `artifact_type`: `plan`
- `artifact_paths`: the master-plan.md just written
- `criteria`: the feature list confirmed in Step 4 and must-haves from Step 9
- `context_paths`: `DDD/projects/<slug>/brief.md`

If BLOCK → fix the flagged gaps in the master plan before initializing project files.
If WARN → surface warnings in the Step 13 output summary.

---

## Step 11 — Initialize project files

Create:

**`DDD/projects/<slug>/brief.md`** — the compiled brief (if not already existing from pd-new-project)

**`DDD/projects/<slug>/plan/active_session.md`**
```markdown
# Active Session

agent: planner
project: <slug>
skill: plan-project
status: complete
session_started: <date>

## Completed
- Master plan created with <n> phases, <n> features, <n> gates
```

Update `DDD/projects/PROJECTS.md`:
- Add row: `| <Project Name> | <slug> | planning | active | <date> |`

---

## Step 12 — Jira sync (optional)

Ask:
```
question: "Want me to sync this plan to Jira?"
options:
  - "Yes — create epics and tickets"
  - "No — keep it local for now"
```

If yes:
- Use Rovo MCP to search for existing Jira project/epics first (never duplicate)
- Create epics per phase, tickets per feature
- Tag tickets: `eng-only`, `needs-design`, `design-only`
- Record Jira keys in master-plan.md

---

## Step 13 — Checkpoint and delegation output

Invoke plan-write-memory.

Present:

```
────────────────────────────────────────
  Plan created: <Project Name>
  Phases: <n> | Features: <n> | Gates: <n>
────────────────────────────────────────

Ready to start:
  • /plan:feature <feature> — detail features for execution
  • /product-designer — start design for needs-design features
  • Eng-only features can start immediately with executor

Blocked (waiting on design):
  • <feature> — needs Gate G1 (design handoff)

Open decisions:
  • <decision> — impacts <feature>

Run /plan:status at any time to check progress.
────────────────────────────────────────
```

---

## Rules

- **Never skip brief intake** — even if the user says "just plan it", extract capabilities first
- **Always confirm with user** at Steps 4 (features), 5 (workstreams), 6 (phases) before proceeding
- **Goal-backward validation is mandatory** — every phase must have must-haves derived from its end state
- **Gates must be explicit** — every cross-workstream dependency needs a named gate
- **Local MD is always created** — Jira is optional sync, never the source of truth
- **Never write to design/ or handoff/** — those are PD territory
