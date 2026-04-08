---
name: design-system-help
model: haiku-4-5
description: >
  Explain the Design System Agent in depth. Triggered by /design-system-help,
  "how does the design system agent work", "explain ds commands", "what is the design system agent",
  "how do tokens work", "how do I build components", "explain the knowledge-base".
---

# Design System Help

Explain the Design System Agent: what it manages, how the knowledge-base works, and when to use each command.

## Procedure

### Step 1 — Load state
Read `design-system/config.md` and `design-system/MEMORY.md`.

### Step 2 — Present explanation

```
## Design System Agent

The Design System Agent manages your Figma design system. It keeps a local knowledge-base
of your tokens, components, and styles — and uses that to build, audit, and document components
with strict token binding (no raw hex values ever).

---

### Knowledge-Base  (`design-system/knowledge-base/`)
Populated by `/ds-init` and refreshed by `/ds-update`. Treat as read-only.

| File | What it contains |
|------|-----------------|
| `tokens.md` | All design tokens (color, spacing, radius, shadow, type) |
| `components.md` | All scanned Figma components with variants and usage |
| `styles.md` | Named paint and effect styles |
| `conventions.md` | Discovered naming and structure conventions |

---

### Memory  (`design-system/memory/`)
Claude-managed. Written at the end of every workflow.

| File | What it contains |
|------|-----------------|
| `REGISTRY.md` | Components built or modified by the agent |
| `TOKEN-GAPS.md` | Tokens requested but not yet created |
| `DECISIONS.md` | Rationale for past design decisions |

---

### Workflow: Building a component

1. `/ds-plan` — Interview to capture requirements, output a build spec
2. `/ds-build` — Execute the spec in Figma (token-bound, no raw values)
3. `/ds-verify` — Screenshot and verify visually
4. `/ds-doc` — Generate documentation frame in Figma
5. `/ds-spec` — Generate engineering spec for developers
6. `/ds-handoff` — Create tracker tickets

---

### Token Rules
- Every fill, stroke, shadow, and spacing value MUST bind to a token.
- If a needed token doesn't exist → the agent proposes a name, logs it to `TOKEN-GAPS.md`, and waits for your confirmation before creating it.
- Never guess or invent tokens — only use what's in `knowledge-base/tokens.md`.

---

### Commands

| Command | When to use |
|---------|------------|
| `/ds-init` | First time setup — scans Figma, populates knowledge-base |
| `/ds-plan` | Before building any new component |
| `/ds-build <component>` | Build a component from a spec |
| `/ds-add-variant <component>` | Add a new variant or state to an existing component |
| `/ds-token <intent>` | Find the right token (e.g. "primary button background") |
| `/ds-update` | Re-scan Figma after you've made manual changes |
| `/ds-audit` | Check all components for token compliance and convention violations |
| `/ds-doc <component>` | Generate a documentation frame in Figma |
| `/ds-spec <component>` | Generate an engineering implementation spec |
| `/ds-handoff <component>` | Create dev tickets in your configured tracker |
| `/ds-verify <component>` | Take a screenshot and verify visually |
| `/ds-feedback` | Tell the agent to remember a preference or correct a behaviour |
| `/ds-memory` | Read, write, or search the memory files directly |
| `/ds-help` | Show live status dashboard (component count, token gaps, recent activity) |

---

**Current config**
- UI Kit: <from config.md>
- Agent version: <from config.md>
- Figma file: <from config.md>
- Components scanned: <from MEMORY.md>
- Open token gaps: <from MEMORY.md>
```

## Rules
- Fill in all `<from ...>` placeholders from the loaded files
- If `knowledge-base/components.md` is empty, add: "Knowledge-base is empty — run `/ds-init` first."
- Keep output scannable — use the tables as presented
