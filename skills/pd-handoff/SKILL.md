---
name: pd-handoff
description: >
  Generate development handoff for a designed and annotated project. Use when the user
  types /pd:handoff, asks to "create handoff", "write the specs", "dev handoff",
  "hand off to development", or wants to package the design for engineering.
  Produces a Figma handoff page and a markdown spec document.
---

# Handoff

Generate the development handoff: a Figma handoff page and a markdown spec document with specs, acceptance criteria, logic, and component map.

---

## Step 1 — Load context

Read:
- `projects/<slug>/brief.md`
- `projects/<slug>/flows.md`
- `projects/<slug>/screen-inventory.md`
- `projects/<slug>/directions.md`
- `projects/<slug>/component-gaps.md`
- `projects/<slug>/active_session.md`
- `design-system/knowledge-base/components.md`
- `design-system/config.md`

If any screens have status `not started` or `designed` (not annotated) → warn:
> "⚠️ Some screens haven't been annotated yet: [list]. Handoff will be incomplete for these. Continue anyway?"

Update `active_session.md`:
```markdown
phase: HANDOFF
status: in_progress
```

---

## Step 2 — Create Figma handoff page

```javascript
await figma.loadAllPagesAsync();
let handoffPage = figma.root.children.find(p => p.name === 'PDA — <Project Name> — Handoff');
if (!handoffPage) {
  handoffPage = figma.createPage();
  handoffPage.name = 'PDA — <Project Name> — Handoff';
}
figma.currentPage = handoffPage;
```

Copy all designed + annotated screens (with their annotation frames) from the Flows page to the Handoff page.

At the top of the handoff page, create a cover frame:
```
[Project Name]
Development Handoff
Version 1.0 — <date>
Designer: [from config or leave blank]
Status: Ready for development
```

Organize by flow: create a labeled section per flow on the handoff page.

`figma_take_screenshot` — verify handoff page looks organized.

---

## Step 3 — Generate markdown handoff document

Write `projects/<slug>/handoff/<slug>-handoff.md`:

```markdown
# Development Handoff: <Project Name>

> Version: 1.0
> Date: <date>
> Status: Ready for development
> Figma: [Handoff page link — update with actual Figma file URL from config.md]

---

## Project Overview

<Brief summary of what's being built, who it's for, and why>

**Platforms:** <list>
**Design system:** <UI kit name from config.md>

---

## Flows in Scope

| Flow | Screens | Platform | Priority |
|------|---------|----------|----------|
| <flow name> | <n> | <platform> | <1-n> |

---

## Screens

<For each screen in screen-inventory.md — one section per screen>

### <Screen Name>

**Flow:** <flow name>
**Platform:** <platform>
**Figma:** Node <figma_node>

#### Purpose
<What this screen does and when a user sees it>

#### Components Used
| Component | Variant | DS Status |
|-----------|---------|-----------|
| <name> | <variant> | in-system / gap-built / placeholder |

#### States
| State | Trigger | Visual Change |
|-------|---------|---------------|
| default | page load | — |
| loading | form submit | skeleton overlay |
| error | validation fail | red borders + error messages |
| empty | no data | empty state component |
| success | action complete | success banner |

#### Logic & Behavior
<Numbered list from annotations>
1. <annotation 1>
2. <annotation 2>
...

#### Acceptance Criteria
- [ ] <specific, testable criteria>
- [ ] <e.g., "Submit button is disabled until all required fields pass validation">
- [ ] <e.g., "On success, user is redirected to /confirmation within 500ms">

#### Edge Cases
- <edge case 1 and expected behavior>
- <edge case 2>

---

<Repeat for each screen>

---

## Component Map

| Component | Source | Variants Used | Notes |
|-----------|--------|---------------|-------|
| <name> | DS (existing) | <variants> | — |
| <name> | DS (built for this project) | <variants> | Built in ds-build |
| <name> | Placeholder | — | Not yet in DS — see Gaps section |

---

## Component Gaps

<If any gaps remain>

| Component | Used On | Properties Needed | Status |
|-----------|---------|-------------------|--------|
| <name> | <screen> | <description> | pending / built |

---

## Design Tokens Used

<List notable token decisions that engineers should know about>

| Token | Value | Used For |
|-------|-------|----------|
| <token> | <value> | <purpose> |

---

## Navigation & Routing

| From | Action | To | Condition |
|------|--------|----|-----------|
| <screen> | <CTA tap / link click> | <screen> | <if any> |

---

## Out of Scope

<Anything explicitly excluded from this design phase>
- <item>
- <item>

---

## Open Questions

<Any unresolved design or product decisions that engineering should flag before building>
- [ ] <question>
- [ ] <question>
```

---

## Step 4 — Review with user

Present:
- Screenshot of Figma handoff page
- Summary of what was written to the markdown doc

Ask:
```
question: "Handoff document ready. Anything to add or correct before finalizing?"
options:
  - "Looks good — finalize"
  - "Add open questions"
  - "Update acceptance criteria for a screen"
  - "Add something to out of scope"
```

Iterate until confirmed.

---

## Step 5 — Finalize

Update `active_session.md`:
```markdown
### Handoff
status: complete
handoff_doc: projects/<slug>/handoff/<slug>-handoff.md
figma_page: PDA — <Project Name> — Handoff
screens_handed_off: <n>
```

Update `projects/PROJECTS.md` — set project status to `handoff-complete`.

Invoke pd-write-memory.

---

## Step 6 — What's next

```
────────────────────────────────────────
✅  Handoff complete: <Project Name>

📄  Spec doc:   projects/<slug>/handoff/<slug>-handoff.md
🎨  Figma page: PDA — <Project Name> — Handoff

<n> screens · <n> flows · <n> components documented

**What's next:** Share the Figma handoff link and spec doc with your development team.

Or:
/pd:status        — See full project summary
/pd:new-project   — Start a new project
/product-designer — Continue with a different task
────────────────────────────────────────
```

---

## Rules

- **Always produce both outputs** — Figma handoff page and markdown spec doc
- **ACs must be testable** — not "button works" but "button is disabled until all required fields are valid"
- **Flag open questions explicitly** — don't silently resolve ambiguity in the spec
- **Component map must be complete** — every component used, its source, and build status
- **Gaps section is required if any placeholders exist** — engineers need to know what's missing
