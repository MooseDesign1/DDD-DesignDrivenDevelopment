<div align="center">

```
 ████████╗  ████████╗  ████████╗
 ██╔═════╗  ██╔═════╗  ██╔═════╗
 ██║    ██  ██║    ██  ██║    ██
 ██║    ██  ██║    ██  ██║    ██
 ██╚═════╝  ██╚═════╝  ██╚═════╝
 ████████╔╝ ████████╔╝ ████████╔╝
 ╚════════╝ ╚════════╝ ╚════════╝
  Design-Driven Development
```

**A Claude Code plugin that connects your Figma UI kit to your codebase.**

Scans your design system, builds a structured knowledge-base, and gives Claude precise project-specific context to build, document, and audit components — without hallucinating tokens or inventing conventions.

![Version](https://img.shields.io/badge/version-0.1.0-A259FF?style=flat-square)
![Claude Code](https://img.shields.io/badge/Claude_Code-required-0ACF83?style=flat-square)
![Figma](https://img.shields.io/badge/Figma_MCP-required-1ABCFE?style=flat-square)

</div>

---

## How It Works

DDD installs into any project that uses Claude Code. Each session it:

1. **Reads** `design-system/config.md` and `design-system/MEMORY.md` to orient itself
2. **Checks** if the knowledge-base is populated — if not, auto-runs `/ds-init`
3. **Loads** only the files needed for the active command, on demand
4. **Enforces** token and convention boundaries — never guesses, always asks

Claude never invents tokens or components. If something isn't in the knowledge-base, it stops and asks.

---

## Requirements

| Requirement | Notes |
|---|---|
| [Claude Code](https://claude.com/claude-code) | CLI v1.0+ |
| [Figma Console MCP](https://github.com/southleft/figma-console-mcp) | Must be connected in Claude Code |
| A Figma file with a UI kit | shadcn, Radix, Material, or custom |

---

## Installation

```bash
cd /your project 
npx design-driven-development 
```

No clone required. The package downloads, installs into your project, and is discarded. Your project is fully self-contained — all skills and templates are copied in.

What gets installed:
- `design-system/` — knowledge-base, memory, and config directories
- `.claude/skills/ds-*` — all design system commands
- `CLAUDE.md` — design agent context injected into every Claude session

**To update**, remove the old skills and re-run:
```bash
rm -rf /path/to/your/project/.claude/skills/ds-*
npx design-driven-development /path/to/your/project
```

---

## First Run

On first launch, Claude detects the empty knowledge-base and automatically starts `/ds-init`.

```bash
cd /path/to/your/project
claude
```

<div align="center">

```
   ▄███████████▄  ✦
  █  ◕       ◕  █
  █      ‿      █
   ▀███████████▀
  ╱   ▄█████▄   ╲

  I now have all your design system sauce  ✦
```

*Your DS assistant after a successful `/ds-init`*

</div>

`/ds-init` will ask you three things:

1. **Figma file URL** — paste any URL from your file
2. **UI kit base** — shadcn, Radix, Material, custom, or other
3. **Ticket tracker** — Jira, Linear, or none

Then it scans your entire Figma file and writes:

| File | Contents |
|---|---|
| `knowledge-base/tokens.md` | All variable collections, grouped by category and mode |
| `knowledge-base/components.md` | All components with variants, properties, children |
| `knowledge-base/styles.md` | Text, color, and effect styles |
| `knowledge-base/conventions.md` | Inferred naming and structure patterns |
| `memory/REGISTRY.md` | Component registry with build status |

---

## Commands

### Scanning

| Command | What It Does |
|---|---|
| `/ds-init` | Bootstrap scan — scans Figma and populates the knowledge-base |
| `/ds-update` | Re-scan Figma and show what changed since last scan |
| `/ds-audit` | Check all components against discovered conventions |

### Building

| Command | What It Does |
|---|---|
| `/ds-plan` | Interview → generate a build spec for a new component |
| `/ds-build` | Build a component in Figma using the knowledge-base |
| `/ds-add-variant` | Add a variant or state to an existing component |
| `/ds-verify` | Screenshot-verify a built component against its spec |

<div align="center">

```
✦  ╲  ▄███████████▄  ╱  ✦
    █  ★       ★  █
    █      ◡      █
     ▀███████████▀
        ▄█████▄

  Yay! another component built  ✦
```

*Your DS assistant after `/ds-build` completes*

</div>

### Documentation & Handoff

| Command | What It Does |
|---|---|
| `/ds-doc` | Generate component documentation from the knowledge-base |
| `/ds-spec` | Generate an engineering implementation spec |
| `/ds-handoff` | Create tickets in your tracker (Jira or Linear) |

<div align="center">

```
   ▄███████████▄
  █  ◠       ◠  █── ノ
  █      ▿      █
   ▀███████████▀
      ▄█████▄   ──›

  Packaged up and shipped!  ✦
```

*Your DS assistant after `/ds-handoff` completes*

</div>

### Utilities

| Command | What It Does |
|---|---|
| `/ds-token` | Find the right token for a design intent |
| `/ds-feedback` | Capture workflow preferences and save to memory |
| `/ds-memory` | View and manage persistent memory files |
| `/ds-help` | Show current system status and all available commands |

---

## Project Structure

```
your-project/
├── design-system/
│   ├── config.md              # Figma file key, UI kit, tracker settings
│   ├── MEMORY.md              # Dashboard: counts, recent activity
│   ├── framework.md           # System overview (auto-generated by /ds-init)
│   ├── knowledge-base/        # Read-only — written by /ds-init and /ds-update
│   │   ├── components.md
│   │   ├── tokens.md
│   │   ├── styles.md
│   │   └── conventions.md
│   └── memory/                # Claude-managed — updated throughout sessions
│       ├── REGISTRY.md        # Per-component build status
│       ├── TOKEN-GAPS.md      # Tokens Claude needed but didn't find
│       ├── DECISIONS-ARCHIVE.md
│       ├── CONVENTIONS-LOG.md
│       ├── AUDIT-LOG.md
│       └── specs/             # Saved build specs per component
└── .claude/
    └── skills/                # Copied ds-* skill files
```

> `knowledge-base/` is **read-only** during normal operation. Only `/ds-init` and `/ds-update` write to it. The `memory/` directory is Claude-managed and updated freely.

---

## Agent Rules

These rules are injected into every Claude session via `CLAUDE.md`:

**Token boundary** — Claude only uses tokens present in `tokens.md`. If no suitable token exists, it logs the gap to `TOKEN-GAPS.md` and waits for confirmation before proceeding.

**Ambiguity** — If anything is unclear (which token, which component, how to interpret a design intent) Claude outputs a numbered question list before taking any Figma action.

**Hard stops** — Claude will not apply an unconfirmed token, will not contradict a convention without approval, and will not modify an existing component unless explicitly asked.

---

## Uninstall

```bash
npx design-driven-development uninstall /path/to/your/project
```

Removes all skill files from `.claude/skills/` and the DDD section from `CLAUDE.md`. The `design-system/` directory is preserved — delete it manually if you no longer need it:

```bash
rm -rf /path/to/your/project/design-system
```

---

## Multiple Projects

Each project gets its own independent knowledge-base and memory. Install into as many as you need:

```bash
npx design-driven-development ~/projects/app-one
npx design-driven-development ~/projects/app-two
```

---

<div align="center">

```
   ▄███████████▄
  █  ◉       ◉  █────✦
  █      ▿      █
   ▀███████████▀
      ▄█████▄
```

*v0.1.0 — Built for [Claude Code](https://claude.com/claude-code)*

</div>
