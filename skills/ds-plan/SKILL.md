---
name: ds-plan
description: >
  Interactive planning interview for a new component. Use when the user types /ds-plan,
  asks to "plan a component", "design a new component", "I need a new component", or
  wants to spec out a component before building. Outputs a confirmed build spec that
  /ds-build consumes.
---

# Plan Component

Interview the user to create a build spec for a new component.

## Procedure

### Step 1 — Load context
Read:
- `design-system/knowledge-base/components.md` — what already exists
- `design-system/knowledge-base/conventions.md` — naming and structure rules
- `design-system/knowledge-base/tokens.md` — available tokens
- `design-system/config.md` — preferences and custom rules
- Any `design-system/memory/feedback_*.md` files related to planning

### Step 2 — Understand the component
Ask one question at a time (skip any already answered):

1. **What component do you need?** — name, purpose, where it will be used
2. **Check existing** — invoke resolve-component to see if it already exists or can be composed
   - If exact match: "This already exists as `<name>`. Want to modify it instead? (`/ds-add-variant`)"
   - If composable: "This could be built from `<components>`. Want to proceed that way?"
   - If new: continue interview
3. **Variants** — what states/variants does it need? (e.g., sizes, types, states)
4. **Content** — what content goes inside? (text, icons, other components)
5. **Behavior** — any interactive behavior? (hover, focus, disabled, error states)
6. **Accessibility** — keyboard navigation, ARIA requirements, screen reader behavior
7. **Responsive** — how does it adapt to different container sizes?

### Step 3 — Resolve tokens
For each design property in the spec, invoke resolve-token:
- Background, border, text colors
- Spacing (padding, gaps)
- Border radius
- Typography (font, size, weight)
- Effects (shadows, etc.)

Log any gaps to TOKEN-GAPS.md. Mark them in the spec as "pending token."

### Step 4 — Draft build spec

```markdown
# Build Spec: <ComponentName>

## Overview
- **Name:** <name>
- **Purpose:** <description>
- **Based on:** <existing components being composed, or "new">

## Variants
| Property | Type | Values | Default |
|----------|------|--------|---------|
| <prop> | <enum/boolean> | <values> | <default> |

## Properties
| Property | Type | Description |
|----------|------|-------------|
| <prop> | <text/boolean/instance> | <description> |

## Structure
<Component>
├── <layer> — <purpose> — <token bindings>
│   ├── <child>
│   └── <child>
└── <layer>

## Token Bindings
| Property | Token | Value |
|----------|-------|-------|
| background | <token> | <value> |
| padding | <token> | <value> |
| gap | <token> | <value> |

## Accessibility
- **Keyboard:** <navigation pattern>
- **ARIA:** <roles, labels>
- **Focus:** <focus behavior>

## Pending
- [ ] <any unresolved tokens or decisions>
```

### Step 5 — Review with user
Present the build spec. Ask:
> Does this spec look right? Any changes before I build?

Iterate until confirmed.

### Step 6 — Save spec
Write to `design-system/memory/specs/<ComponentName>.md`.
Invoke write-memory to update MEMORY.md.

## Rules
- One question at a time — don't overwhelm
- Always check resolve-component before starting from scratch
- Always include accessibility section
- If custom rules in config.md apply, follow them
- Never proceed to build without user confirmation of the spec
