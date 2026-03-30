---
name: ds-handoff
description: >
  Create tickets in the configured tracker for component handoff to engineering.
  Use when the user types /ds-handoff, asks to "create tickets", "hand off components",
  or wants to track component implementation work.
---

# Handoff to Engineering

Create tickets in the configured issue tracker.

## Procedure

### Step 1 — Load context
Read:
- `design-system/config.md` — tracker type, project, connection details
- `design-system/memory/specs/` — available specs

If no tracker configured:
> No ticket tracker configured. Run `/ds-feedback` to set one up,
> or I can output the ticket content as markdown for you to copy.

### Step 2 — Identify what to hand off
If not specified, ask:
1. Which component(s)?
2. Single ticket or epic with sub-tasks?

Load the engineering spec from `memory/specs/<name>-engineering.md`.
If no spec exists, offer to run `/ds-spec` first.

### Step 3 — Draft ticket content

**Single component ticket:**
```
Title: Implement <ComponentName>
Description:
  ## Overview
  <from spec>

  ## Props & Variants
  <from spec>

  ## Token Mapping
  <from spec>

  ## Acceptance Criteria
  - [ ] All variants implemented
  - [ ] Tokens mapped correctly
  - [ ] Accessibility requirements met
  - [ ] Matches Figma design (link to component)
```

**Epic with sub-tasks:**
```
Epic: <ComponentName>
  ├── Task: Implement base component
  ├── Task: Add variant support
  ├── Task: Implement accessibility
  ├── Task: Add unit tests
  └── Task: Documentation
```

### Step 4 — Confirm with user
Present the ticket content. Ask:
> Ready to create these tickets? Or any changes first?

### Step 5 — Create tickets

**Jira:**
Use the Atlassian MCP tools to create issues in the configured project.

**Linear:**
Use the Linear MCP tools (if available) or output for manual creation.

**None / other:**
Output the ticket content as markdown for the user to copy.

### Step 6 — Write back
Invoke write-memory:
- Note in REGISTRY.md that handoff was created (ticket IDs if available)
- Update MEMORY.md

## Rules
- Always include a link to the Figma component in the ticket
- Always include the engineering spec content
- Never create tickets without user confirmation
- If no spec exists, generate one first via /ds-spec
