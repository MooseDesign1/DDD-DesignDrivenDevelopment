---
name: ds-init
description: >
  Bootstrap scan of a Figma file. Auto-triggered when knowledge-base/components.md is empty
  (detected by CLAUDE.md boot check). Also use when the user types /ds-init, asks to
  "scan my Figma file", "set up the design system", or "initialize". Scans Figma for
  components, tokens, and styles, then populates the knowledge-base.
---

# Initialize Design System

Scan a Figma file to discover its design system and populate the knowledge-base.

## Procedure

### Step 1 — Load feedback
Read `design-system/memory/feedback_*.md` if any exist. Apply entries tagged `all` or `ds-init` throughout this workflow.

### Step 2 — Check if already initialized
Read `design-system/knowledge-base/components.md`.
- If it contains component entries (not just the template header) → warn user that
  re-running will overwrite. Ask to confirm or suggest `/ds-update` instead.
- If empty/template only → proceed.

### Step 3 — Ask basics

Ask the user (skip any already answered):
1. **Figma file URL** (required) — extract fileKey from the URL
2. **UI kit base** — "What UI kit is this based on?" (shadcn, Radix, Material, custom, other)
3. **Ticket tracker** — "Do you use a ticket tracker for handoff?" (Jira, Linear, none)
   - If Jira/Linear: ask for project key/ID

### Step 4 — Scan tokens
Call `figma_get_variables` to retrieve all variable collections.

Organize into `design-system/knowledge-base/tokens.md`:
- Group by collection name
- Within each collection, group by category (colors, spacing, radius, typography, etc.)
  inferred from token naming patterns
- For collections with modes (e.g., light/dark), create columns per mode
- Use table format per the schema in the design spec

Format:
```
## Collection: <name>

### <Category>
| Token | <Mode1> | <Mode2> | ... |
|-------|---------|---------|-----|
| <name> | <value> | <value> | ... |
```

For single-mode collections:
```
### <Category>
| Token | Value |
|-------|-------|
| <name> | <value> |
```

### Step 5 — Scan components
Call `figma_search_components` to get all components.
For each component (or a representative sample if >50), call `figma_get_component_details`
to get variants, properties, and children.

Organize into `design-system/knowledge-base/components.md`:
- One section per component
- List variants (property name + values)
- List properties (name + type)
- List children (for compound components)
- Note which components are used inside others ("Used in")
- Note the source (UI kit name or "custom")

Format:
```
## <ComponentName>
- **Variants**: <prop> (<value1>, <value2>, ...)
- **Properties**: <prop> (<type>)
- **Children**: <child1>, <child2>, ...
- **Used in**: <parent1>, <parent2>, ...
- **Source**: <ui-kit-name|custom>
```

### Step 6 — Scan styles
Call `figma_get_styles` to get text styles, color styles, and effect styles.

If `figma_get_styles` fails or returns zero styles (possible on dynamic-page documents where the sync API throws), fall back to `figma_execute` with async code:
```javascript
const [textStyles, paintStyles, effectStyles] = await Promise.all([
  figma.getLocalTextStylesAsync(),
  figma.getLocalPaintStylesAsync(),
  figma.getLocalEffectStylesAsync(),
]);
return JSON.stringify({
  text: textStyles.map(s => ({ id: s.id, name: s.name, fontSize: s.fontSize, fontFamily: s.fontName?.family, fontWeight: s.fontName?.style })),
  paint: paintStyles.map(s => ({ id: s.id, name: s.name })),
  effect: effectStyles.map(s => ({ id: s.id, name: s.name, effects: s.effects })),
});
```

Organize into `design-system/knowledge-base/styles.md`:
- Separate sections for text, color, and effect styles
- Table format per the schema in the design spec

### Step 6b — Read documentation page
Before inferring conventions, check if the Figma file has a documentation or about page:

```javascript
await figma.loadAllPagesAsync();
const docPage = figma.root.children.find(p =>
  /about|documentation|docs|readme|📖|guide/i.test(p.name)
);
if (docPage) {
  const textNodes = docPage.findAllWithCriteria({ types: ['TEXT'] });
  return JSON.stringify(textNodes.map(n => ({ name: n.name, chars: n.characters?.slice(0, 2000) })));
}
return null;
```

If a documentation page exists, extract its theming/token sections and include them verbatim in the output below.

### Step 7 — Infer conventions
Analyze the scanned data for patterns:

**Naming patterns** — look at component names, token names, style names:
- What casing? (PascalCase, camelCase, kebab-case, etc.)
- Any prefixes or namespaces?
- Separators (/, -, _, .)

**Structure patterns** — look at component relationships:
- Compound components? (Card > CardHeader, CardContent)
- Flat or nested variant organization?
- Common property types?

**Token patterns** — look at variable naming:
- Category prefixes? (color-, spacing-, etc.)
- Scale patterns? (1, 2, 3 or sm, md, lg)

**Alias architecture** — inspect token values from `figma_get_variables`:
- Sample semantic/alias-named variables (those named with semantic terms like `color/background`, `text/primary`, etc.)
- Check their value type: is it `VARIABLE_ALIAS` (pointer to another variable) or a raw RGBA/float?
- If semantic variables are `VARIABLE_ALIAS` type → this is an **alias chain architecture**. Document it as a hard constraint.
- Identify which collections are primitives (raw values) vs. semantics (aliases)
- For each mode in the semantic collection: classify as `brand` (mutable, user customizes) or `reference` (read-only, do not modify) based on the mode name (e.g., `your_brand` = brand, `shadcn`/`shadcn-dark` = reference)

For each inferred convention:
- Assign confidence: **high** (>80% consistent), **medium** (50-80%), **low** (<50%)
- Low-confidence: present the raw data and ask the user to define the convention
- Conflicting patterns: present both interpretations, ask user to pick one

Write to `design-system/knowledge-base/conventions.md`.

### Step 7b — Write theming conventions
If an alias chain architecture was detected (semantic variables are `VARIABLE_ALIAS`), write `design-system/knowledge-base/theming-conventions.md`:

```markdown
# Theming Conventions

## Token Architecture
Semantic variables are VARIABLE_ALIAS pointers — they reference primitives, never hold raw hex/RGBA values.

<primitive-collection> (raw values)
    ↓ referenced by
<semantic-collection> (alias pointers, N modes)
    ↓ consumed by
components

## Hard Rules
- **NEVER** set a raw RGBA/hex value on a semantic variable — it breaks the alias chain
- **ALWAYS** set semantic variable values as VARIABLE_ALIAS references to primitives
- To introduce a new color: add it to `<primitive-collection>` first, then alias the semantic to it

## Theming Workflow
1. Add a new primitive to `<primitive-collection>` (e.g. `Brand/primary = #0D99FF`)
2. In the target mode of `<semantic-collection>`, update the semantic variable to alias that primitive
3. Never write raw values onto semantic variables

## Modes
| Mode | Collection | Type | Rule |
|------|-----------|------|------|
<one row per mode, classified as brand/reference>

## Notes from documentation page
<paste relevant sections from the Figma documentation page if found, or "No documentation page found">
```

### Step 8 — Generate framework.md
Write `design-system/framework.md` with:
- System overview (UI kit, counts)
- Component organization (how grouped in Figma)
- Token architecture (collections, modes)
- Composition patterns (detected nesting)
- File references (file key, URL)

### Step 9 — Initialize memory
- Populate `design-system/memory/REGISTRY.md` with all discovered components (status: "scanned")
- Write `design-system/config.md` with project details
- Update `design-system/MEMORY.md` dashboard with counts

### Step 10 — Present summary

Show the user:
```
   ▄███████████▄  ✦
  █  ◕       ◕  █
  █      ‿      █
   ▀███████████▀
  ╱   ▄█████▄   ╲

  I now have all your design system sauce  ✦

## Scan Complete

**UI Kit:** <name>
**Figma File:** <file key>

### Discovered
- Components: <count>
- Tokens: <count> across <N> collections (<modes> modes)
- Styles: <count> (text: X, color: Y, effect: Z)

### Inferred Conventions
<list conventions with confidence levels>

### Questions
<any low-confidence conventions or ambiguities to resolve>
```

Wait for user confirmation before considering init complete.

## Rules
- If `figma_search_components` returns no results, try the manual fallback:
  ```javascript
  const sets = figma.root.findAllWithCriteria({ types: ['COMPONENT_SET'] });
  const components = figma.root.findAllWithCriteria({ types: ['COMPONENT'] });
  ```
- If the Figma file is very large (>100 components), scan in batches and show progress
- Never write to memory files before the scan is complete — write all at once at the end
- Store the Figma file key in config.md for future scans

## ▶ What's Next

`/ds-plan` — plan your first component

*Just say "do it", "continue", or "yes" to start — no need to type the command*
