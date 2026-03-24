---
name: ds-spec
description: >
  Generate an engineering implementation spec for a component. Use when the user types
  /ds-spec, asks for a "spec", "implementation guide", "engineering handoff", or needs
  developer documentation for a component.
---

# Engineering Spec

Generate an implementation specification for engineers.

## Procedure

### Step 1 — Load context
Read:
- `design-system/knowledge-base/components.md`
- `design-system/knowledge-base/tokens.md`
- `design-system/knowledge-base/conventions.md`
- `design-system/memory/specs/<ComponentName>.md` — build spec if exists
- `design-system/config.md` — UI kit info

### Step 2 — Identify component
If not specified, ask which component to spec.
Load full details from components.md. Optionally inspect in Figma for accuracy.

### Step 3 — Generate spec

Write to `design-system/memory/specs/<ComponentName>-engineering.md`:

```markdown
# <ComponentName> — Engineering Spec

## Overview
<What this component is, when to use it>

## API

### Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| <prop> | <type> | <default> | <description> |

### Variants
| Variant | Values | Default | Notes |
|---------|--------|---------|-------|
| <variant> | <values> | <default> | <notes> |

### Slots/Children
| Slot | Purpose | Required |
|------|---------|----------|
| <slot> | <purpose> | <yes/no> |

## Token Mapping
| Design Token | CSS Property | Value |
|-------------|-------------|-------|
| <token> | <property> | <resolved value> |

## States
| State | Visual Changes | Token Overrides |
|-------|---------------|-----------------|
| default | — | — |
| hover | <changes> | <overrides> |
| focus | <changes> | <overrides> |
| disabled | <changes> | <overrides> |

## Accessibility
- **Role:** <ARIA role>
- **Keyboard:** <key interactions>
- **Labels:** <aria-label / aria-labelledby requirements>
- **Focus management:** <focus behavior>

## Usage Example
<Code example using the project's UI kit framework>

## Notes
<Any implementation notes, edge cases, or gotchas>
```

### Step 4 — Present to user
Show the spec in chat. Ask for review:
> Engineering spec saved to `design-system/memory/specs/<name>-engineering.md`.
> Review and let me know if anything needs adjusting.

### Step 5 — Write back
Invoke write-memory to update MEMORY.md.

## Rules
- Always include accessibility section
- Use the project's UI kit framework for code examples (from config.md ui_kit)
- Token mapping should reference actual token names from the knowledge-base
- If the component has no build spec, generate from the components.md entry
