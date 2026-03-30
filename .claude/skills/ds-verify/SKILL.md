---
name: ds-verify
description: >
  Screenshot-based visual verification of a component in Figma. Use when the user types
  /ds-verify, asks to "check how it looks", "verify the component", "take a screenshot",
  or wants visual confirmation after a build step.
---

# Verify Component

Screenshot and visually verify a component in Figma.

## Procedure

### Step 1 — Identify target
If the user hasn't specified:
- Ask which component to verify
- Or use the most recently built/modified component from the current session

### Step 2 — Navigate and screenshot
1. Use `figma_get_selection` or search for the component
2. Navigate to the component with `figma_navigate`
3. Take a screenshot with `figma_take_screenshot`

### Step 3 — Analyze
Compare the screenshot against:
- The build spec (if one exists in memory/specs/)
- The knowledge-base entry for this component
- General design quality: alignment, spacing, proportions, visual balance

### Step 4 — Report

**If everything looks correct:**
> Component `<name>` looks good. Verified: alignment, spacing, proportions, token usage.

**If issues found:**
> Found <N> issues with `<name>`:
> 1. <issue description> — <suggested fix>
> 2. <issue description> — <suggested fix>
>
> Want me to fix these?

### Step 5 — Iterate (if fixing)
If the user asks to fix issues:
1. Apply fixes via figma_execute
2. Re-screenshot
3. Re-analyze
4. Max 3 iterations — if still not right after 3, report remaining issues

## Rules
- Always take the screenshot at a zoom level that shows the full component
- If the component has variants, verify at least the default variant (offer to check others)
- Never silently adjust — report discrepancies clearly
- Compare at high zoom for spacing/alignment details

## ▶ What's Next

`/ds-doc` — generate a documentation frame for this component in Figma

*Just say "do it", "continue", or "yes" to start — no need to type the command*

Or jump ahead to `/ds-spec` to generate the engineering implementation spec
