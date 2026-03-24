---
name: resolve-component
description: >
  Internal skill for deciding whether to use an existing component, compose from
  existing components, or build new. Called by ds-plan and ds-build when a component
  need arises. Never invoked directly by the user.
---

# Resolve Component

Decide how to fulfill a component need: reuse, compose, or build new.

## Procedure

### Step 1 — Load component reference
Read `design-system/knowledge-base/components.md`.

### Step 2 — Search for match
Compare the needed component against the inventory by:
1. Name match (exact or close)
2. Purpose match (does an existing component serve the same function?)
3. Structure match (similar variants, properties, children)

### Step 3 — Decision tree

```
Component needed: [X]
├─ Exact match in components.md?
│  └─ YES → return { action: "use", component: "<name>" }
├─ Partial match (right component, missing variant/state)?
│  └─ YES → return { action: "add-variant", component: "<name>", missing: "<variant>" }
├─ Can be composed from 2+ existing components?
│  └─ YES → return { action: "compose", components: [...], plan: "<how>" }
└─ No match
   └─ return { action: "build-new", suggestedName: "<name per conventions>" }
```

### Step 4 — Return result
Return the decision with rationale to the calling skill. The calling skill
decides whether to proceed or ask the user for confirmation.

## Rules
- Always check conventions.md for naming when suggesting new component names
- If the search is ambiguous (multiple partial matches), return all candidates
- Never silently pick one match over another — surface the choice
