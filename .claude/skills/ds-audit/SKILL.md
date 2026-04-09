---
name: ds-audit
model: opus
effort: high
description: >
  System-wide compliance audit of the design system. Use when the user types /ds-audit,
  asks to "audit", "check compliance", "run a health check", or wants a review of
  components against the discovered conventions and tokens.
---

# Audit Design System

Check all components against discovered conventions and token usage.

## Procedure

### Step 1 — Load references
Read:
- `design-system/knowledge-base/conventions.md`
- `design-system/knowledge-base/tokens.md`
- `design-system/knowledge-base/components.md`
- `design-system/config.md` — custom rules

### Step 2 — Determine scope
If not specified, audit the full file. Otherwise accept:
- A specific page or section name
- A specific component name
- A category (e.g., "all buttons", "all form components")

### Step 3 — Scan components in Figma
Use `figma_search_components` to get components in scope.
For each component, use `figma_get_component_details` to inspect.

### Step 4 — Run checks

For each component:

| # | Check | How |
|---|-------|-----|
| 1 | **Naming** | Does name match conventions.md patterns? |
| 2 | **Token compliance** | Are visual properties bound to known tokens? |
| 3 | **Property structure** | Do variants/properties match components.md? |
| 4 | **Layer naming** | Do layer names follow conventions? |
| 5 | **Sizing** | Uses fill/hug appropriately? No unnecessary fixed sizes? |
| 6 | **Composition** | Are child components used correctly? |
| 7 | **Custom rules** | Any rules from config.md satisfied? |

For each check: PASS, FAIL (with description), or SKIP (with reason).

### Step 5 — Generate report

```
## Audit Report — <scope>
**Date:** <date>
**Components checked:** <count>

### Summary
- PASS: <count>
- FAIL: <count>
- SKIP: <count>

### Issues by Component

#### <ComponentName>
- [ ] FAIL: <check name> — <description> — <suggested fix>
- [x] PASS: <check name>

#### <ComponentName>
- [x] PASS: all checks
```

### Step 6 — Save report
Write to `design-system/memory/AUDIT-LOG.md` with timestamp.

### Step 7 — Write back
Invoke write-memory to update MEMORY.md with audit results.

## Rules
- SKIP checks where conventions.md doesn't define a rule (not FAIL)
- For large files (>50 components), show progress and offer to audit in batches
- Present the full report before offering to fix issues
- If context is above 50% used → recommend `/clear` before fixing
