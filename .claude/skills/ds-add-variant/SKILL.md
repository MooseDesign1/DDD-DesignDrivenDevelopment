---
name: ds-add-variant
model: sonnet-4-6
description: >
  Add a variant or state to an existing component. Use when the user types
  /ds-add-variant, asks to "add a variant", "add a state", "extend a component",
  or needs to add a new variant property value or state to an existing component.
---

# Add Variant

Add a variant or state to an existing component in Figma.

## Procedure

### Step 1 — Load context
Read `design-system/memory/active_session.md` if it exists — pick up component name,
figma_node, inspection snapshot, confirmed token gaps, and exploration result if already done.

Read `design-system/memory/feedback_*.md` if any exist and apply entries tagged `all` or `ds-add-variant`.

Read:
- `design-system/knowledge-base/components.md`
- `design-system/knowledge-base/tokens.md`
- `design-system/knowledge-base/conventions.md`
- `design-system/knowledge-base/theming-conventions.md` (alias chain rules, if exists)
- `design-system/config.md`

### Step 2 — Identify target
If not specified, ask:
1. **Which component?** — search components.md for the name
2. **What variant/state to add?** — new property value, new boolean state, visual style change, etc.

Verify the component exists in Figma via `figma_search_components` + `figma_get_component_details`.
Show the current variant structure.

### Step 2b — Classify the request
Determine whether this is:
- **Structural variant** — adding a new property value or boolean state (e.g., "add a destructive variant") → proceed to Step 3
- **Visual / style change** — changing how the component looks (e.g., "make it 3D", "add shadows", "change the style") → trigger **Exploration Phase** first (Step 2c)

When in doubt, treat as a visual change and run the exploration phase.

### Step 2c — Exploration phase (visual/style changes only)
Do NOT touch the real component. Build 3–4 concept frames on a separate exploration page:

1. Create a temporary page named `Exploration - <ComponentName>`:
   ```javascript
   await figma.loadAllPagesAsync();
   let explorePage = figma.root.children.find(p => p.name.startsWith('Exploration -'));
   if (!explorePage) {
     explorePage = figma.createPage();
     explorePage.name = 'Exploration - <ComponentName>';
   }
   figma.currentPage = explorePage;
   ```

2. Build 3–4 concept frames with **distinct visual directions**. Each frame must:
   - Use `primaryAxisSizingMode = 'AUTO'` (never fixed height)
   - Set all text nodes: `textNode.textAutoResize = 'HEIGHT'` then `textNode.resize(textNode.width, 1)`
   - Be labeled clearly (e.g., "Concept A — Subtle 3D", "Concept B — High Contrast 3D")
   - Use placeholder values for tokens (document what tokens it would need)

3. Take a screenshot with `figma_take_screenshot`, present it to the user.

4. Ask: "Which direction do you want to pursue? You can also share a mockup or reference and I'll explore that alongside these."

5. Iterate based on feedback (max 2 rounds). Only proceed when the user explicitly picks a direction.

### Step 2d — Token audit (required before any implementation)
Before modifying the real component, audit token coverage for the chosen design:

1. List every visual property the change will affect (fills, strokes, effects, radius, spacing, typography)
2. For each property, check `design-system/knowledge-base/tokens.md`:
   - **Covered** — a token exists and will be used as a variable binding
   - **Gap** — no token exists; note what needs to be created
3. Check `design-system/knowledge-base/theming-conventions.md` (if it exists) for alias rules
4. Present the gap list:
   ```
   ## Token Audit

   **Covered:** <list of tokens that will be bound>

   **Gaps (need to create):**
   - <property>: needs a primitive in `<collection>` → alias in `<semantic-collection>`
   ```
5. Wait for user confirmation before creating any missing tokens.

### Step 2e — Inspect current state (required before modifying strokes/effects)
Before touching any existing component node, read and document its current state:

```javascript
const node = figma.currentPage.findOne(n => n.name === '<ComponentName>');
const state = {
  fills: node.fills,
  strokes: node.strokes,
  strokeStyleId: node.strokeStyleId,
  effects: node.effects,
  effectStyleId: node.effectStyleId,
  // ... other relevant properties
};
return JSON.stringify(state);
```

Note:
- If a **gradient stroke** exists (`fills[i].type === 'GRADIENT_LINEAR'` or similar) → preserve it as a named paint style before any modification
- If **effect styles** are bound (`effectStyleId !== ''`) → document the style name before overwriting

### Step 3 — Plan the change
Present what will happen:
```
## Adding to: <ComponentName>

**Current variants:**
- <property>: <existing values>

**Adding:**
- <property>: <new value>

**This will:**
1. Duplicate the default variant
2. Modify it for the new state
3. Update the component set
4. Bind tokens: <list>
```

Wait for confirmation.

### Step 4 — Build the variant
1. Navigate to the component in Figma
2. Find the component set
3. Duplicate an appropriate existing variant
4. Modify the duplicate:
   - Rename per conventions
   - Update visual properties
   - Bind tokens for the new state
5. Add to the component set

### Step 5 — Screenshot and verify
Take a screenshot showing the full component set with the new variant.
Check alignment, consistency with existing variants.

### Step 6 — Update knowledge-base
Update the component's entry in `design-system/knowledge-base/components.md`:
- Add the new variant value to the variants list

### Step 7 — Write back
Invoke write-memory:
- Update REGISTRY.md (status: "modified", notes about variant added)
- Update MEMORY.md

## Rules
- Always show the current state and planned change before modifying
- Never modify the component without confirmation
- The new variant must follow the same token bindings and conventions as existing variants
- Always screenshot the result
- **Never apply raw hex values** — all fills, strokes, and colors must be variable bindings. If a token doesn't exist, surface the gap and wait for confirmation before creating it.
- **Always use async style setters** — `strokeStyleId =` and `effectStyleId =` throw on dynamic-page documents. Use `await node.setStrokeStyleIdAsync(id)` and `await node.setEffectStyleIdAsync(id)` instead.
- **Inspect before modifying** — read and document existing strokes, effects, and fills before any change. Preserve gradient strokes and named effect styles — do not silently overwrite them.
- **Run exploration phase for all visual/style changes** — do not jump to implementation for any request that changes the look of a component. Build concept frames first, get user sign-off, then implement.
