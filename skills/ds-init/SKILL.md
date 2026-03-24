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

### Step 1 — Check if already initialized
Read `design-system/knowledge-base/components.md`.
- If it contains component entries (not just the template header) → warn user that
  re-running will overwrite. Ask to confirm or suggest `/ds-update` instead.
- If empty/template only → proceed.

### Step 2 — Ask basics

Ask the user (skip any already answered):
1. **Figma file URL** (required) — extract fileKey from the URL
2. **UI kit base** — "What UI kit is this based on?" (shadcn, Radix, Material, custom, other)
3. **Ticket tracker** — "Do you use a ticket tracker for handoff?" (Jira, Linear, none)
   - If Jira/Linear: ask for project key/ID

### Step 3 — Scan tokens
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

### Step 4 — Scan components
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

### Step 5 — Scan styles
Call `figma_get_styles` to get text styles, color styles, and effect styles.

Organize into `design-system/knowledge-base/styles.md`:
- Separate sections for text, color, and effect styles
- Table format per the schema in the design spec

### Step 6 — Infer conventions
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

For each inferred convention:
- Assign confidence: **high** (>80% consistent), **medium** (50-80%), **low** (<50%)
- Low-confidence: present the raw data and ask the user to define the convention
- Conflicting patterns: present both interpretations, ask user to pick one

Write to `design-system/knowledge-base/conventions.md`.

### Step 7 — Generate framework.md
Write `design-system/framework.md` with:
- System overview (UI kit, counts)
- Component organization (how grouped in Figma)
- Token architecture (collections, modes)
- Composition patterns (detected nesting)
- File references (file key, URL)

### Step 8 — Initialize memory
- Populate `design-system/memory/REGISTRY.md` with all discovered components (status: "scanned")
- Write `design-system/config.md` with project details
- Update `design-system/MEMORY.md` dashboard with counts

### Step 9 — Present summary

Show the user:
```
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
