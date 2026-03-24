---
name: ds-add-variant
description: >
  Add a variant or state to an existing component. Use when the user types
  /ds-add-variant, asks to "add a variant", "add a state", "extend a component",
  or needs to add a new variant property value or state to an existing component.
---

# Add Variant

Add a variant or state to an existing component in Figma.

## Procedure

### Step 1 — Load context
Read:
- `design-system/knowledge-base/components.md`
- `design-system/knowledge-base/tokens.md`
- `design-system/knowledge-base/conventions.md`
- `design-system/config.md`

### Step 2 — Identify target
If not specified, ask:
1. **Which component?** — search components.md for the name
2. **What variant/state to add?** — new property value, new boolean state, etc.

Verify the component exists in Figma via `figma_search_components` + `figma_get_component_details`.
Show the current variant structure.

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
