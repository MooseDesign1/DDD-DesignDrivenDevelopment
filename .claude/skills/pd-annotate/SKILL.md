---
name: pd-annotate
description: >
  Annotate designed screens with interaction logic, behavior notes, and edge cases.
  Use when the user types /pd:annotate, asks to "annotate the screens", "add annotations",
  "document the logic", "label interactions", or wants to prepare screens for
  development handoff with behavioral context.
---

# Annotate

Add logic and behavior annotations to final designed screens. One annotation frame per screen, 60px gap to the right.

---

## Step 1 — Load context

Read:
- `design-system/projects/<slug>/brief.md` — annotation preference (native or custom), if already set
- `design-system/projects/<slug>/screen-inventory.md` — screens with status `designed`
- `design-system/projects/<slug>/active_session.md`
- `design-system/knowledge-base/components.md` — check if annotation component exists

Update `active_session.md`:
```markdown
phase: ANNOTATE
status: in_progress
```

---

## Step 2 — Annotation preference

Check `brief.md` for `Annotation Preference`. If already set, skip this step.

If not set, ask:
```
question: "How would you like annotations on the screens?"
options:
  - "Custom annotation component — numbered callouts next to each screen"
  - "Figma native annotations — I prefer the built-in Figma annotation tool"
```

Save preference to `brief.md` under `## Annotation Preference`.

---

## Step 3 — Set up annotation component (if custom)

If preference is **custom**:

Check `design-system/knowledge-base/components.md` for an existing annotation component.

**If annotation component exists** → note its node ID for instantiation.

**If no annotation component exists** → build one:

Navigate to the design system's component page (from `config.md`).

Create the annotation component:
```javascript
// Annotation marker (small numbered circle)
const marker = figma.createFrame();
marker.name = 'Annotation Marker';
marker.resize(20, 20);
marker.cornerRadius = 10;
// Bind fill to a prominent color token (e.g., brand primary or a dedicated annotation color)
// Set as component

// Annotation legend row
const legendRow = figma.createFrame();
legendRow.name = 'Annotation Row';
// Auto-layout: horizontal, align items center, gap 8
// Children: marker instance + text node for annotation content

// Annotation legend container
const legend = figma.createFrame();
legend.name = 'Annotation Legend';
// Auto-layout: vertical, gap 8, padding 16
// Has a label at top: "Annotations"
// Children: multiple annotation rows

// Combine into component
```

After building: `figma_take_screenshot` → verify it looks clean.
Add to `design-system/knowledge-base/components.md`.

---

## Step 4 — Navigate to Flows page

```javascript
await figma.loadAllPagesAsync();
const page = figma.root.children.find(p => p.name === 'PDA — <Project Name> — Flows');
figma.currentPage = page;
```

---

## Step 5 — Annotate each screen

For each screen in `screen-inventory.md` with status `designed`:

### 5a — Read the screen

Get the screen node:
```javascript
const screenNode = await figma.getNodeByIdAsync('<figma_node>');
```

Analyze the screen's interactive elements and states:
- Interactive elements (buttons, links, inputs, toggles, cards)
- States (hover, focus, active, disabled, error, loading)
- Conditional content (empty states, logged-in vs logged-out)
- Transitions or navigation actions
- Edge cases or validation rules

### 5b — Write annotation content

For each annotation point, write a concise note:
- **[N] Element name / interaction** — behavior description. Include: trigger, outcome, any conditions.

Example:
```
[1] Submit button — Disabled until all required fields are valid. On tap: validates inline, shows field errors if any, else submits form and navigates to confirmation screen.
[2] Email field — Validates on blur. If format invalid: shows red border + "Enter a valid email" below field.
[3] Back link — Returns to previous screen. Does not clear form data.
[4] Empty state — Shown when user has no saved items. "Get started" CTA links to onboarding flow.
```

### 5c — Create annotation frame (custom) or add native annotations

**Custom annotation frame:**
```javascript
// Place annotation frame to the right of the screen
const annotationFrame = figma.createFrame();
annotationFrame.name = `Annotations — <Screen Name>`;
annotationFrame.x = screenNode.x + screenNode.width + 60; // 60px gap
annotationFrame.y = screenNode.y;
annotationFrame.resize(320, 1); // width fixed, height auto
// primaryAxisSizingMode = 'AUTO'
```

Instantiate the annotation component, populate with numbered items.

**Native Figma annotations:**
Use the Figma annotations API to attach annotations directly to elements:
```javascript
// Note: native annotations are set per-node via node.annotations
// Build array of annotation objects from the content list
```

### 5d — Add numbered markers on screen (custom only)

For custom annotations, place small numbered circle markers on the screen over each annotated element:
```javascript
const markerInstance = annotationMarkerComponent.createInstance();
markerInstance.x = elementNode.x + elementNode.width - 10;
markerInstance.y = elementNode.y - 10;
```

### 5e — Screenshot

`figma_take_screenshot` — verify screen + annotation frame side by side look clean.

### 5f — Update screen inventory

Mark screen status: `annotated` in `screen-inventory.md`.

---

## Step 6 — All screens annotated

Update `active_session.md`:
```markdown
### Annotate
status: complete
annotation_style: <native | custom>
screens_annotated: <n>
```

Invoke pd-write-memory.

---

## Step 7 — What's next

```
────────────────────────────────────────
✅  Annotations complete

<n> screens annotated.
Style: <native Figma annotations | custom annotation component>

All annotated screens on: "PDA — <Project Name> — Flows"

────────────────────────────────────────
```

**▶ What's Next**

`/pd:handoff` — Generate the development handoff document

*Just say "do it", "continue", or "yes" to start — no need to type the command*

Or jump ahead to:
- `/pd:status` — See full project overview

---

## Rules

- **Annotation preference is per-project** — store in `brief.md`, not re-asked once set
- **60px gap** — annotation frames always 60px to the right of the screen frame
- **Be specific in annotations** — "navigates to X screen" not "navigates somewhere"
- **Cover edge cases** — empty states, errors, validation, auth-dependent content, loading
- **Never modify the screen itself** — only add annotation elements alongside
- **If annotation component doesn't exist** — build it, add to DS knowledge-base before annotating
