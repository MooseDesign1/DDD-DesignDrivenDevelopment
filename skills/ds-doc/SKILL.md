---
name: ds-doc
description: >
  Generate Figma-based documentation for a component. Use when the user types /ds-doc,
  asks to "document a component", "add docs", "create documentation", or wants to create
  the usage guide for a component.
---

# Document Component

Generate a documentation frame in Figma for a component.

## Procedure

### Step 1 — Load context
Read:
- `design-system/knowledge-base/components.md` — component details
- `design-system/memory/specs/<ComponentName>.md` — build spec if it exists
- `design-system/config.md` — doc preferences
- `design-system/memory/feedback_*.md` — any doc-related feedback

### Step 2 — Identify component
If not specified, ask which component to document.
Load its details from components.md and optionally from Figma via `figma_get_component_details`.

### Step 3 — Generate documentation frame
Create a documentation frame in Figma adjacent to the component. Include sections:

**Required sections:**
1. **Title** — component name
2. **Description** — what it is and when to use it
3. **Variants** — visual showcase of all variants with labels
4. **Properties** — table of all configurable properties
5. **Usage guidelines** — do's and don'ts

**Conditional sections (include if relevant):**
6. **Accessibility** — keyboard, ARIA, focus, screen reader behavior
   (always include for interactive components)
7. **Composition** — how this component is built from other components
8. **Token bindings** — which tokens are used and where

### Step 4 — Build in Figma
Use `figma_execute` to create the documentation frame:
- Create a frame with auto-layout (vertical, padding, gap)
- Add text nodes for each section
- Instantiate the component to show variants inline
- Use the system's typography tokens for headings and body text

### Step 5 — Screenshot and verify
Take a screenshot of the documentation frame.
Check readability, completeness, alignment.

### Step 6 — Write back
Invoke write-memory:
- Note in REGISTRY.md that docs were created for this component
- Update MEMORY.md

## Rules
- Always include accessibility section for interactive components
- Follow any doc preferences from config.md
- Use the system's own typography tokens for the doc frame
- Place the doc frame near the component, not on a separate page (unless config says otherwise)
