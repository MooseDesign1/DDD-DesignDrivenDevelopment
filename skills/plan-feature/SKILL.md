---
name: plan-feature
model: opus
effort: high
description: >
  Feature-level planner with two-pass design awareness. Use when the user types /plan:feature,
  says "plan this feature", "detail the login feature", "break down [feature]", or wants to
  produce a detailed execution bundle for a specific feature.
  Pass 1 plans backend + defines design scope. Pass 2 (after handoff) completes the bundle.
---

# Plan Feature

Detail a specific feature into a self-contained execution bundle with tasks, design context, and human checkpoints.

**Effort level: medium.** Be concise and direct — plan and delegate, don't over-analyze.

---

## Step 1 — Load context

Read:
- `DDD/projects/<slug>/plan/master-plan.md`
- If no master plan → "Run `/plan:project` first to create a master plan."

---

## Step 2 — Select feature

If not specified in the user's request, show features from master-plan.md and ask:
```
question: "Which feature do you want to detail?"
options:
  - "<feature 1>"
  - "<feature 2>"
  - "<feature 3>"
```

Check if this feature has been planned before by looking for `DDD/projects/<slug>/plan/features/<feature-slug>.md`.

---

## Step 3 — Determine pass

Check the feature's workstream tags from master-plan.md:

**If feature has NO `needs-design` tasks:**
→ Single pass. Plan everything now. Skip to Step 4a.

**If feature HAS `needs-design` tasks:**
→ Check if handoff doc exists at `DDD/projects/<slug>/handoff/<feature-slug>-handoff.md`
  - **No handoff doc** → **Pass 1** (plan backend, define design scope)
  - **Handoff doc exists** → **Pass 2** (read handoff, complete the bundle)

**If Pass 2 was already done** (feature plan has `status: ready-for-execution`):
→ Re-run Pass 2 (design may have iterated). Warn user: "Re-running Pass 2 — will re-diff backend."

---

## Step 4a — Pass 1: Plan backend + define design scope

### Goal-backward must-haves

Derive from the feature's end state:
> "What must be TRUE when this feature is complete?"

List 3-7 must-haves. These become the verification criteria in the bundle.

### Eng-only / infra tasks

For each task that doesn't need design:

```markdown
### Task: <Title>
- **Workstream:** eng-backend | infra
- **Wave:** 1
- **Approach:** <specific technical approach — what to build, how, what to avoid and why>
- **Files:** <exact file paths>
- **Acceptance criteria:**
  - [ ] <specific, testable>
- **Depends on:** <other tasks or "none">
- **Complexity:** S | M | L
```

### Needs-design tasks (scope only)

For each task that needs design input:

```markdown
### Task: <Title>
- **Workstream:** design → eng-frontend
- **Plan status:** pass-1 (awaiting design handoff)

#### What design must answer
- <question 1 — e.g., "What states does the login form have?">
- <question 2 — e.g., "Is there a forgot password flow?">

#### Parallel backend work
- <what eng can build now that this UI will need>
- <e.g., "Auth API endpoint can be built now">

#### Frontend implementation
Awaiting design handoff doc.
Re-run `/plan:feature <feature>` after design delivers to complete Pass 2.

#### Gate
- Gate: <gate name from master-plan.md>
- Criteria:
  - [ ] Figma screens finalized and annotated
  - [ ] pd-handoff doc produced at DDD/projects/<slug>/handoff/<feature>-handoff.md
  - [ ] Component gaps resolved or documented
```

### Product decisions (if any)

```markdown
### Decide: <Decision>
- **Type:** product-decision
- **Options:** <known options>
- **Impacts:** <what tasks are blocked>
- **Needed by:** <when>
```

### Wave assignment

Group tasks by dependency:
```
Wave 1: <tasks with no deps — can start immediately>
Wave 2: <tasks depending on wave 1>
Wave 3: <tasks after design handoff — awaiting>
```

### Save and delegate

Write `DDD/projects/<slug>/plan/features/<feature-slug>.md` with Pass 1 content.
Update master-plan.md feature status.
Invoke plan-write-memory.

Present:
```
────────────────────────────────────────
  Feature planned (Pass 1): <Feature Name>
  Tasks: <n> eng-only ready | <n> awaiting design
────────────────────────────────────────

Start now (Wave 1):
  • <task> → executor / dev agent

Design needed:
  • Run /product-designer for <feature> screens
  • After handoff, run /plan:feature <feature> for Pass 2

Open decisions:
  • <decision if any>
────────────────────────────────────────
```

---

## Step 4b — Pass 2: Complete the execution bundle

Read the pd-handoff doc at `DDD/projects/<slug>/handoff/<feature-slug>-handoff.md`.
Also read `DDD/projects/<slug>/design/component-gaps.md` for DS gap status.

### Inline design context

Extract from the handoff doc and place inline in the feature plan:

```markdown
## Design Context (from handoff)

### Screens
| Screen | Flow | Platform | States | Figma Node |
|--------|------|----------|--------|------------|
| <screen> | <flow> | <platform> | <states> | <node> |

### Interactions & Logic
<Numbered list from handoff annotations>
1. <interaction 1>
2. <interaction 2>

### Component Map
| Component | Source | Variant | DS Status |
|-----------|--------|---------|-----------|
| <name> | DS (existing) | <variant> | in-system |
| <name> | Gap (built) | <variant> | gap-built |
| <name> | Placeholder | — | pending |

### States per Screen
| Screen | State | Trigger | Visual Change |
|--------|-------|---------|---------------|
| <screen> | default | page load | — |
| <screen> | loading | form submit | skeleton |
| <screen> | error | validation fail | error messages |
```

### Add DS gap tasks

For each unresolved component gap from `component-gaps.md`:

```markdown
## DS Gap Tasks

### Build: <ComponentName>
- **Workstream:** design-system
- **Properties needed:** <from gaps doc>
- **Used on:** <screens>
- **Figma spec:** <description>
- **Code spec:** <description>
- **CHECKPOINT:** human verifies component in Figma + code output
```

### Diff backend (Pass 1 vs design requirements)

Compare the handoff doc's requirements against Pass 1 backend tasks:

```markdown
## Backend Revisions (surfaced by design)

| What changed | Pass 1 assumption | Design requires | Impact |
|---|---|---|---|
| <endpoint/schema/field> | <what was planned> | <what design needs> | <new task or modify existing> |
```

If no revisions → note "No backend changes required — Pass 1 plan holds."

For each revision:
- Minor (add field, adjust response) → update existing task's plan
- Significant (new endpoint, new table) → create new task
- Flag anything that invalidates already-built backend work

### Complete frontend tasks

For each `needs-design` task that was `awaiting-design-handoff`:

```markdown
### Task: <Title>
- **Workstream:** eng-frontend
- **Plan status:** pass-2 (design handoff received)
- **Wave:** 3

#### Build from handoff
1. <component 1> — use <DS component or build custom>
2. <component 2> — wire to <API endpoint>
3. <state management> — <approach>

#### Acceptance criteria
- [ ] <from handoff ACs>
- [ ] Matches Figma design
- [ ] All states implemented (loading, error, empty, success)

- **Complexity:** <now estimable>
- **CHECKPOINT:** human verifies UI matches design
```

### Sequence into execution stages

```markdown
## Execution Stages

### Stage 1: DS Gaps
<DS gap tasks — build missing components>
CHECKPOINT: verify components in Figma + code

### Stage 2: Backend
<All eng-backend tasks — original + revisions>
CHECKPOINT: verify APIs work

### Stage 3: Frontend
<All eng-frontend tasks — wired to APIs, using DS components>
CHECKPOINT: verify UI matches design

## Verification (must-haves)
- [ ] <must-have 1>
- [ ] <must-have 2>
- [ ] <must-have n>
```

### Update feature plan status

Update the feature plan header:
```markdown
> Status: ready-for-execution
```

Update master-plan.md feature and gate status.
Invoke plan-write-memory.

Present:
```
────────────────────────────────────────
  Feature bundle complete: <Feature Name>
  Status: ready-for-execution

  Stage 1: <n> DS gap tasks
  Stage 2: <n> backend tasks (<n> revisions from design)
  Stage 3: <n> frontend tasks

  Run executor agent to build this feature.
────────────────────────────────────────
```

---

## Rules

- **Pass 1 never plans frontend implementation** — only defines what design must answer
- **Pass 2 always inlines design specs** — the feature plan must be self-contained after Pass 2
- **Backend diff is mandatory in Pass 2** — design ALWAYS has the potential to change backend assumptions
- **Must-haves are derived goal-backward** — not copied from task descriptions
- **Wave assignment reflects real dependencies** — same-wave tasks must not block each other
- **Checkpoints between every execution stage** — human verification is non-negotiable
- **Never write to design/ or handoff/** — read only
