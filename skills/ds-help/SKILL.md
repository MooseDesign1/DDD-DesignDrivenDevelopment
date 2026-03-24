---
name: ds-help
description: >
  Show design system status and available commands. Use when the user types /ds-help,
  asks "what can you do", "show status", "what commands are available", or wants an
  overview of the design system state.
---

# Design System Help

Show current system status and available commands.

## Procedure

### Step 1 — Load state
Read:
- `design-system/MEMORY.md`
- `design-system/config.md`

### Step 2 — Present dashboard

```
## Design System Agent — Status

**Project:** <from config.md>
**UI Kit:** <from config.md>
**Agent Version:** <from config.md>

### Counts
| | Count |
|---|---|
| Components (scanned) | <from MEMORY.md> |
| Components (built/modified) | <from REGISTRY.md if loaded> |
| Tokens | <from MEMORY.md> |
| Styles | <from MEMORY.md> |
| Token Gaps (open) | <from MEMORY.md> |

### Available Commands

| Command | Purpose |
|---------|---------|
| `/ds-init` | Scan Figma file, populate knowledge-base |
| `/ds-plan` | Plan a new component (interview → spec) |
| `/ds-build` | Build a component in Figma |
| `/ds-add-variant` | Add variant/state to existing component |
| `/ds-doc` | Generate component documentation |
| `/ds-spec` | Generate engineering implementation spec |
| `/ds-handoff` | Create tickets in tracker |
| `/ds-token` | Find the right token for a design intent |
| `/ds-update` | Re-scan Figma, show changes |
| `/ds-audit` | Check all components against conventions |
| `/ds-verify` | Screenshot-verify a component |
| `/ds-feedback` | Capture workflow preferences |
| `/ds-memory` | Manage persistent memory |

### Recent Activity
<from MEMORY.md>
```

## Rules
- If knowledge-base is empty, prominently note that `/ds-init` needs to run
- Keep the output concise — this is a quick reference, not a deep dive
