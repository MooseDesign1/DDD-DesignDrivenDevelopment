---
name: ds-build
description: >
  Full build pipeline for a component in Figma. Use when the user types /ds-build,
  asks to "build a component", "create the component", or is ready to construct a
  planned component. Requires a confirmed build spec from /ds-plan (or runs planning
  inline).
---

# Build Component

Construct a component in Figma from a build spec.

## Procedure

### Step 1 — Load or create build spec
Read `design-system/memory/active_session.md` if it exists — pick up component name,
figma_node, confirmed token gaps, and any steps_remaining from an in-progress session.

Check if a build spec exists in `design-system/memory/specs/`:
- If YES → load it, confirm it's still the plan
- If NO → ask the user: "No build spec found. Want to run `/ds-plan` first, or
  describe what you want to build?"
  - If they describe it inline, run a condensed planning interview

Also load:
- `design-system/knowledge-base/components.md`
- `design-system/knowledge-base/tokens.md`
- `design-system/knowledge-base/theming-conventions.md` (alias chain rules, if exists)
- `design-system/config.md`
- Any relevant `design-system/memory/feedback_*.md`

### Step 2 — Find or create parent container
Before creating any component:
1. Check config.md for a preferred page/section (e.g., "Components" page)
2. Navigate to that page, or ask which page to use
3. Find or create a Section/Frame to contain the new component

```javascript
await figma.loadAllPagesAsync();
let page = figma.root.children.find(p => p.name === '<pageName>');
if (!page) { /* ask user which page */ }
figma.currentPage = page;

let section = figma.currentPage.findOne(n => n.type === 'SECTION' && n.name === '<sectionName>');
if (!section) {
  section = figma.createSection();
  section.name = '<sectionName>';
}
```

### Step 3 — Build the component frame
Invoke build-frame for the main component structure:
- Create the outer frame per the spec
- Set auto-layout direction, padding, gap
- Bind tokens to spacing/padding properties

### Step 4 — Add children
For each child in the spec's structure:
- **Existing component** → search with `figma_search_components`, instantiate
- **Text** → create text node, set content, bind typography tokens
- **Frame/container** → invoke build-frame recursively
- **Icon** → instantiate from the system's icon components

### Step 5 — Set up variants (if component set)
If the spec defines variants:
1. Build the default variant first
2. Duplicate for each variant combination
3. Modify each duplicate per the spec
4. Combine into a component set

### Step 6 — Token audit and bind
Before binding, run a token audit:
1. List every visual property that needs a token (fills, strokes, effects, radius, spacing, typography)
2. Check `design-system/knowledge-base/tokens.md` for each — mark as **covered** or **gap**
3. Check `design-system/knowledge-base/theming-conventions.md` (if it exists) for alias rules
4. Present gaps and wait for confirmation before creating missing tokens

Then bind all covered tokens:
- Look up the token in knowledge-base/tokens.md
- Find the corresponding Figma variable
- Bind with `setBoundVariable`
- **Never set raw hex/RGBA values** on semantic variables — surface a gap instead

For style bindings use async setters:
- `await node.setStrokeStyleIdAsync(id)` — never `node.strokeStyleId =`
- `await node.setEffectStyleIdAsync(id)` — never `node.effectStyleId =`

### Step 7 — Screenshot and verify
Take a screenshot with `figma_take_screenshot`.
Analyze: alignment, spacing, proportions, visual balance.
If issues found, fix and re-screenshot (max 3 iterations).

### Step 8 — Validate
Invoke validate-component to run the post-build checklist.
Report results. Fix any FAIL items if straightforward.

### Step 9 — Write back
Invoke write-memory:
- Add to REGISTRY.md (status: "built", date, notes)
- Update MEMORY.md counts
- Log any token gaps encountered
- Note any convention decisions made

### Step 10 — Report
Present to user:
```
✦  ╲  ▄███████████▄  ╱  ✦
    █  ★       ★  █
    █      ◡      █
     ▀███████████▀
        ▄█████▄

  Yay! another component built  ✦

## Build Complete: <ComponentName>

- Variants: <count>
- Token bindings: <count>
- Validation: <pass/fail count>
- Token gaps: <count> (logged to TOKEN-GAPS.md)
- Screenshot: [verified]

Component is in <page> > <section>.
```

## Rules
- Never build without a spec (inline or from file)
- Never place components on blank canvas — always in a Section or Frame
- Always screenshot after building — do not skip visual verification
- If a needed component doesn't exist, do NOT build it inline — flag it and continue
- Follow feedback files for build preferences (e.g., screenshot frequency)
- If context is above 50% used → recommend `/clear` before next workflow
- **Never apply raw hex/RGBA values** — all visual properties must be token/variable bindings. Surface gaps, wait for confirmation.
- **Always use async style setters** — `await node.setStrokeStyleIdAsync(id)` and `await node.setEffectStyleIdAsync(id)` instead of direct assignment.
- **Text nodes in exploration or concept frames** must set `textAutoResize = 'HEIGHT'` and `node.resize(node.width, 1)`. Parent frames must use `primaryAxisSizingMode = 'AUTO'`.
