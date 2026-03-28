---
name: ddd-help
description: >
  Explain the DDD (Design-Driven Development) framework as a whole. Triggered by /ddd-help,
  "what is DDD", "explain the framework", "what agents do I have", "how does this work",
  "what can I do here", "show me everything", "overview of the design tools".
---

# DDD Help — Framework Overview

Explain the DDD framework: what it is, which agents it includes, and how they work together.

## Output

Present the following:

```
## Design-Driven Development (DDD)

DDD is a Claude Code framework for end-to-end product and design system work inside Figma.
It ships two agents that work together:

---

### 1. Design System Agent  (`/ds-*` commands)
Manages your Figma design system — tokens, components, documentation, and engineering handoff.

| Command | What it does |
|---------|-------------|
| `/ds-init` | Scan your Figma file, build the knowledge-base |
| `/ds-plan` | Plan a new component (interview → spec) |
| `/ds-build` | Build a component in Figma with token bindings |
| `/ds-add-variant` | Add a variant or state to an existing component |
| `/ds-token` | Find the right token for a design intent |
| `/ds-update` | Re-scan Figma for changes |
| `/ds-audit` | Audit all components against conventions |
| `/ds-doc` | Generate component documentation in Figma |
| `/ds-spec` | Generate an engineering implementation spec |
| `/ds-handoff` | Create tracker tickets for dev handoff |
| `/ds-verify` | Screenshot-verify a component visually |
| `/ds-feedback` | Save workflow preferences or corrections |
| `/ds-memory` | Read, write, or search persistent memory |
| `/ds-help` | Show design system status dashboard |

**Start here:** `/ds-init` — scans your Figma file and populates the knowledge-base.

---

### 2. Product Designer Agent  (`/product-designer` + phase commands)
Runs end-to-end product design: from brief → discovery → flows → concepts → screens → handoff.

| Command | What it does |
|---------|-------------|
| `/product-designer` | Main entry point — start or resume a project |
| `/pd-new-project` | Kick off a brand new design project |
| `/pd-discover` | Discovery phase — research and ideation |
| `/pd-define` | Define phase — user flows and screen inventory |
| `/pd-concept` | Concept phase — explore design directions |
| `/pd-design` | Design phase — build final hi-fi screens |
| `/pd-annotate` | Annotate screens with logic and interactions |
| `/pd-handoff` | Generate dev handoff documentation |
| `/pd-status` | Show project progress across all phases |
| `/pd-resume` | Resume an in-progress session |

**Start here:** `/product-designer` — it will ask what you want to work on.

---

### How they connect
- The Product Designer uses your design system's tokens and components via the knowledge-base.
- When screens require components that don't exist, the Product Designer flags a gap — resolved with `/ds-plan` + `/ds-build`.
- Both agents share `design-system/` as their single source of truth.

---

### Meta commands

| Command | What it does |
|---------|-------------|
| `/ddd-help` | This overview |
| `/design-system-help` | Deep dive on the Design System Agent |
| `/product-design-help` | Deep dive on the Product Designer Agent |
| `/ddd-update` | Upgrade DDD skills to the latest version |

---

**Version:** <read agent_version from design-system/config.md>
**Figma file:** <read figma_file_url from design-system/config.md>
```

## Rules
- Always read `design-system/config.md` to fill in version and Figma file URL
- Keep output scannable — this is a reference, not a tutorial
- If knowledge-base hasn't been initialised yet, add a prominent note: "Run `/ds-init` first to scan your Figma file before using either agent."
