---
name: pd-design
description: >
  Design phase — build final hi-fi screens. Use when the user types /pd:design,
  asks to "design the screens", "build the final screens", "hi-fi", "finalize",
  or is ready to produce production-ready designs using the design system.
  Orchestrates pd-screen-builder, ds-plan, and ds-build for component gaps.
---

# Design

Build final high-fidelity screens using the design system. The second diamond of Double Diamond.

---

## Step 1 — Load context

Read:
- `projects/<slug>/brief.md`
- `projects/<slug>/flows.md`
- `projects/<slug>/directions.md` — locked directions per screen
- `projects/<slug>/screen-inventory.md` — screens and their status
- `projects/<slug>/component-gaps.md` — known gaps
- `projects/<slug>/active_session.md`
- `design-system/knowledge-base/components.md`
- `design-system/knowledge-base/tokens.md`
- `design-system/knowledge-base/theming-conventions.md` (if exists)
- `design-system/config.md`

If no locked directions exist and concepting was not skipped → recommend running `/pd:concept` first.
If concepting was skipped → confirm user wants to proceed directly to hi-fi.

Update `active_session.md`:
```markdown
phase: DESIGN
status: in_progress
```

---

## Step 2 — Set up Figma flows page

```javascript
await figma.loadAllPagesAsync();
let page = figma.root.children.find(p => p.name === 'PDA — <Project Name> — Flows');
if (!page) {
  page = figma.createPage();
  page.name = 'PDA — <Project Name> — Flows';
}
figma.currentPage = page;
```

Create a section per flow:
```javascript
const section = figma.createSection();
section.name = '<Flow Name> — <Platform>';
```

---

## Step 3 — Design queue

Present the screen list from `screen-inventory.md`, filtered to `status: not started`.

Ask:
```
question: "Which flow should we start with?"
options:
  - "[Flow 1 name] — <n> screens"
  - "[Flow 2 name] — <n> screens"
  - "A specific screen (tell me which one)"
```

---

## Step 4 — For each screen

### 4a — Load direction

Read the locked concept direction for this screen from `directions.md`.
If no direction was locked (screen was added after concepting), ask:
> "No concept was locked for [screen name]. Describe the layout direction or pick one of the existing directions from another screen."

### 4b — Invoke pd-screen-builder

Pass to pd-screen-builder:
- Screen name and purpose
- Flow and platform
- Locked concept direction
- Parent section node

pd-screen-builder handles:
- Component lookups (resolve-component)
- Token bindings (resolve-token)
- Component gap detection and logging (pd-gap-report)
- Building the frame with auto-layout

### 4c — Component gap handling

If pd-screen-builder returns a gap:
- Log to `component-gaps.md`
- Ask:
```
question: "Missing component: [name]. How should we handle it?"
options:
  - "Build it now — trigger ds-plan → ds-build"
  - "Use a placeholder and continue — I'll build it later"
  - "Skip this screen and come back"
```
  - **Build now** → invoke ds-plan, then ds-build. On completion, resume screen.
  - **Placeholder** → create a labeled rectangle frame ("TODO: [component name]"), continue.
  - **Skip** → move to next screen, add this one to the end of the queue.

### 4d — Screenshot and verify

`figma_take_screenshot` after each screen.
Check: layout consistency, spacing, token usage, content hierarchy.
Max 2 fix iterations per screen.

### 4e — Update screen inventory

Mark screen status: `designed` in `screen-inventory.md`.
Add Figma node ID.

Update checkpoint in `active_session.md`:
```markdown
current_screen: <screen name>
screens_completed: <n>
screens_remaining: <list>
```

---

## Step 5 — Flow complete

When all screens in a flow are done, `figma_take_screenshot` of the full flow section.
Present to user and ask:
```
question: "Flow complete: [flow name]. What's next?"
options:
  - "Start next flow: [name]"
  - "Review this flow before continuing"
  - "All flows done — move to annotations"
```

---

## Step 6 — All flows complete

Update `active_session.md`:
```markdown
### Design
status: complete
screens_designed: <n>
component_gaps: <n resolved / n pending>
```

Invoke pd-write-memory.

---

## Step 7 — What's next

```
────────────────────────────────────────
✅  Design phase complete

<n> screens designed across <n> flows.
<n> component gaps resolved · <n> pending placeholders

All screens on Figma page: "PDA — <Project Name> — Flows"

**What's next:** /pd:annotate — Add logic and behavior annotations

Or:
/pd:status        — See full project overview
/pd:handoff       — Skip annotations and go straight to handoff
/product-designer — Continue with a different task
────────────────────────────────────────
```

---

## Rules

- **Never design without a direction** — always reference locked concept direction per screen
- **Always use DS components** — no custom components unless a gap is explicitly logged and resolved
- **Token bindings only** — no raw hex/RGBA. Surface gaps, confirm before creating tokens.
- **Async style setters** — `await node.setStrokeStyleIdAsync(id)`, `await node.setEffectStyleIdAsync(id)`
- **Screenshot every screen** — never skip visual verification
- **Checkpoint after each screen** — protect against context loss
- **Gaps don't block the flow** — log, use placeholder, continue
