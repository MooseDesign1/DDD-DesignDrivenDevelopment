---
name: validate-component
model: sonnet
effort: medium
description: >
  Internal skill for post-build validation of a component. Called by ds-build after
  construction is complete. Checks naming, token compliance, structure, and conventions.
---

# Validate Component

Post-build checklist to verify a component meets the design system's conventions.

## Procedure

### Step 1 — Load references
Read:
- `design-system/knowledge-base/conventions.md`
- `design-system/knowledge-base/tokens.md`
- `design-system/knowledge-base/components.md`
- `design-system/config.md` (for custom rules)

### Step 2 — Run checklist

| # | Check | How to Verify |
|---|-------|---------------|
| 1 | **Naming** — matches conventions.md patterns | Compare component name against naming rules |
| 2 | **Token compliance** — all bound values use tokens from KB | Inspect variable bindings on the component |
| 3 | **Layer naming** — child layers follow naming conventions | Check layer names against conventions |
| 4 | **Variant completeness** — all planned variants exist | Compare against build spec |
| 5 | **Properties** — all planned properties are exposed | Check component property definitions |
| 6 | **Sizing** — uses fill/hug appropriately, no fixed values where flex expected | Inspect sizing modes |
| 7 | **Custom rules** — any rules from config.md are satisfied | Check each custom rule |

### Step 3 — Report

For each check:
- PASS → note it
- FAIL → describe what's wrong and suggest the fix
- SKIP → explain why (e.g., convention not defined for this check)

### Step 4 — Return
Return the report to the calling skill. If any checks FAIL, the calling skill
decides whether to fix now or flag for later.

## Rules
- Never silently skip a failing check
- If conventions.md doesn't define a rule for a check category, mark as SKIP (not FAIL)
- Custom rules from config.md are treated with the same weight as convention rules
