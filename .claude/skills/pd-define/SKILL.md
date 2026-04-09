---
name: pd-define
model: sonnet
effort: medium
description: >
  Define phase of product design. Use when the user types /pd:define,
  asks to "map flows", "define user flows", "create IA", "list screens",
  "information architecture", or wants to structure what needs to be designed
  before concepting. Outputs a flow map and screen inventory.
---

# Define

Map user flows, information architecture, and build the screen inventory. The convergent phase of the first diamond.

---

## Step 1 — Load context

Read:
- `projects/<slug>/brief.md`
- `projects/<slug>/design/research.md` (if it exists)
- `projects/<slug>/design/active_session.md`

If no active project → prompt to run `/pd:new-project`.

Update `active_session.md`:
```markdown
phase: DEFINE
status: in_progress
```

---

## Step 2 — Identify flows

Based on brief and research, list the primary user flows. Present to user:

```
Based on your brief, here are the flows I see:

**Flow 1: [Name]**
User goal: <what the user is trying to accomplish>
Entry point: <where this flow starts>
Exit point: <where it ends / what success looks like>

**Flow 2: [Name]**
...
```

Ask:
```
question: "Does this cover all the flows you need to design?"
options:
  - "Yes — this is complete"
  - "Add a flow"
  - "Remove or rename one"
  - "The order/priority is different"
```

Iterate until confirmed. Note which flows are in scope for this project.

---

## Step 3 — Platform and breakpoints

Ask:
```
question: "What platforms are we designing for?"
options:
  - "Mobile only (iOS / Android)"
  - "Desktop only"
  - "Both mobile and desktop"
  - "Responsive web (mobile-first)"
  - "Something else"
```

For each platform, confirm the primary breakpoints/form factors.

---

## Step 4 — Screen inventory

For each confirmed flow, map every screen and state:

```
Flow: <name> — <platform>

| Screen | Purpose | Key States | Entry From | Exits To |
|--------|---------|------------|------------|----------|
| <name> | <one line> | default, empty, error, loading | <screen or entry> | <screen> |
```

Ask user to review per flow. Add/remove screens as needed.

**Naming convention for screens:**
`[Flow Name] — [Screen Name] — [Platform]`
Example: `Onboarding — Email Signup — Mobile`

---

## Step 5 — IA structure

If the product has navigation (not just a linear flow), map the IA:

```
## Information Architecture

[Home]
├── [Section 1]
│   ├── [Screen A]
│   └── [Screen B]
├── [Section 2]
│   └── [Screen C]
└── [Settings / Profile]
    └── [Screen D]
```

Present and confirm. Note which nodes map to which flow screens.

---

## Step 6 — Concept queue

Based on the screen inventory, suggest a concept queue — what to concept first:

```
Suggested concept queue (you can reorder):
1. [Core flow, primary screen — highest design complexity]
2. [Supporting flow, key screen]
3. [Empty/error states — often overlooked]
...
```

Ask:
```
question: "Does this queue look right for concepting?"
options:
  - "Yes — use this order"
  - "I want to reorder"
  - "Skip concepting — go straight to design"
  - "I'll concept manually in Figma"
```

Save confirmed queue to `active_session.md`.

---

## Step 7 — Write flows.md and update screen-inventory.md

**`projects/<slug>/design/flows.md`:**
```markdown
# Flows: <Project Name>

> Phase: Define
> Date: <date>

## Flows in Scope
| Flow | Platform | Screen Count | Priority |
|------|----------|--------------|----------|
| <name> | <platform> | <n> | <1-n> |

## Flow Details

### <Flow Name>
**Goal:** <user goal>
**Entry:** <entry point>
**Exit:** <success state>

| Step | Screen | Purpose |
|------|--------|---------|
| 1 | <screen> | <purpose> |
| 2 | <screen> | <purpose> |

## Information Architecture
<IA tree — if applicable>
```

Update `screen-inventory.md` with all screens:
```
| <Screen Name> | <Flow> | <Platform> | not started | | |
```

---

## Step 8 — Checkpoint

Update `active_session.md`:
```markdown
### Define
status: complete
flow_count: <n>
screen_count: <n>
concept_queue: [<item1>, <item2>, ...]
platforms: [<list>]
```

Invoke pd-write-memory.

---

## Step 9 — What's next

```
────────────────────────────────────────
✅  Define complete

<n> flows · <n> screens inventoried

Concept queue ready:
  1. <first item>
  2. <second item>
  ...

────────────────────────────────────────
```

**▶ What's Next**

`/pd:concept` — Explore design directions

*Just say "do it", "continue", or "yes" to start — no need to type the command*

Or jump ahead to:
- `/pd:design` — Skip concepting and go straight to hi-fi
- `/pd:status` — See full project overview
