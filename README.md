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

**A Claude Code plugin that connects your Figma design system to your codebase.**

Two agents. One for building components. One for designing full products.

![Version](https://img.shields.io/badge/version-0.2.0-A259FF?style=flat-square)
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
5. **Checks** for DDD updates on startup and nudges you if a newer version is available

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

npx design-driven-development@latest
```

No clone required. The package downloads, installs into your project, and is discarded. Your project is fully self-contained.

What gets installed:

```
your-project/
├── design-system/          ← knowledge-base, memory, config, projects
├── .claude/
│   ├── skills/             ← all DDD skill files
│   ├── hooks/              ← version-check hook (runs on session startup)
│   └── settings.json       ← SessionStart hook registered here
└── CLAUDE.md               ← DDD context injected into every Claude session
```

**To update**, re-run from inside your project — skills are always overwritten, your knowledge-base and memory are never touched:

```bash
cd your-project
npx design-driven-development
```

Or from inside a Claude session: just say **"update DDD"** or run `/ddd-update`.

---

## First Run

On first launch, Claude detects the empty knowledge-base and automatically starts `/ds-init`.

```bash
cd your-project
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

</div>

`/ds-init` asks three things:

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
| `knowledge-base/theming-conventions.md` | Alias chain rules and mode semantics (if detected) |
| `memory/REGISTRY.md` | Component registry with build status |

---

## The Two Agents

DDD ships with two primary agents. Use whichever fits the work.

| Agent | Command | What it does |
|---|---|---|
| **Design System Designer** | `/design-system-designer` | Build, restyle, and theme individual components |
| **Product Designer** | `/product-designer` | Take a product from brief to fully designed, annotated, and handed-off flows |

Both agents work from the same knowledge-base and share component and token context.

---

## `/design-system-designer` — Component Agent

The primary way to work with your design system. A unified agent that handles all component building, restyling, and theme work in a single conversational flow.

**You don't need to know which command to use.** Just describe what you want:

```
"Build me a tooltip component"
"Make the button look more elevated with shadows"
"Add a destructive variant to the alert"
"Change the brand color to indigo"
"Apply a dark mode to the system"
```

### How it classifies your intent

`/design-system-designer` identifies what kind of work you need, then routes to the right workflow:

| What you say | Route |
|---|---|
| "build", "create", "I need a", "new [component]" | **New component** — spec → token audit → build → verify |
| "make it look", "restyle", "redesign", "[adjective]-ify" | **Visual change** — explore concepts → token audit → implement |
| "add a [state]", "add a variant", "add hover/disabled" | **Structural variant** — token audit → add to component set |
| "change the theme", "brand color", "dark mode" | **Theme change** — alias chain enforcement → primitives → semantics |

If your request is ambiguous, it asks one question with a native picker — no open-ended text needed.

### Workflow: Visual / style change

When you ask to *change how a component looks*, the agent never jumps straight to implementation. It runs an exploration phase first:

1. **Inspect** — reads the component's current fills, strokes, and effects before touching anything
2. **Explore** — builds 3–4 concept frames on a temporary `Exploration - <ComponentName>` page in Figma
3. **You pick** — implementation doesn't start until you make an explicit choice
4. **Token audit** — maps every visual property to existing tokens, lists gaps, waits for confirmation
5. **Implement** — applies the chosen direction using variable bindings only. Never writes raw hex values
6. **Verify** — screenshots the final result

### Workflow: Theme change

1. **Load alias rules** — reads `theming-conventions.md` to understand your token architecture
2. **Plan** — shows every primitive and alias that will change before touching anything
3. **Execute** — adds new primitives first, then updates semantic variables as `VARIABLE_ALIAS` references
4. **Validate** — screenshots affected components to confirm the theme propagated

### Session checkpoints

For complex work, `/design-system-designer` writes progress to `design-system/memory/active_session.md` after each phase. If you need to `/clear` context mid-exploration, your work isn't lost:

```
Found an in-progress session: visual change on Button.
Exploration is complete — you chose Concept B.
Resume from token audit, or start fresh?
[Resume]  [Start fresh]
```

---

## `/product-designer` — Product Design Agent

<div align="center">

```
   ▄███████████▄  ✦
  █  ◑       ◑  █
  █      ◡      █
   ▀███████████▀
  ╱   ▄█████▄   ╲

  Brief in. Shipped designs out.  ✦
```

</div>

An end-to-end product design agent that follows the **Double Diamond** framework — from a brief or PRD all the way to fully designed, annotated, and development-ready flows in Figma.

**Start a new project:**

```
/pd:new-project
```

Or just describe what you want:

```
"I need to design a donor portal"
"Let's concept the checkout flow"
"Design the onboarding screens"
"Create the handoff for the dashboard"
```

### The Double Diamond workflow

```
DISCOVER          DEFINE            DEVELOP           DELIVER
────────          ──────            ───────           ───────
Ingest brief  →   User flows    →   Concepts      →   Hi-fi screens
Research &        IA mapping        Lo-fi Figma       Annotations
ideation          Screen            Direction         Handoff doc
                  inventory         selection
```

Each phase has a dedicated command, or let `/product-designer` infer where you are and route automatically.

### Phase commands

| Command | Phase | What happens |
|---|---|---|
| `/pd:new-project` | Init | Ingest or write a project brief, initialize project memory |
| `/pd:discover` | Discover | Research synthesis, design challenge framing |
| `/pd:define` | Define | User flows, IA, screen inventory, concept queue |
| `/pd:concept` | Develop | 3 written directions → lo-fi Figma → iterate → lock |
| `/pd:design` | Deliver | Hi-fi screens built with your design system |
| `/pd:annotate` | Deliver | Logic and behavior annotations next to each screen |
| `/pd:handoff` | Deliver | Figma handoff page + markdown spec doc |
| `/pd:status` | Any | Project dashboard — phase, screens, gaps, what's next |
| `/pd:resume` | Any | Resume after a `/clear` — restores from checkpoint |

### Starting a project

`/pd:new-project` asks one question first:

```
Do you have a brief or PRD ready?
[Yes — I have one]   [No — help me write one]
```

If **yes**: paste it, share a URL, or link a Figma file — the agent reads it and extracts key signals.

If **no**: the agent runs a series of focused questions (product, user, problem, flows, platforms, constraints, success metrics) and writes a structured brief for you.

### Concepting

For each item in your concept queue, the agent:

1. Writes **3 distinct directions** in text — named, described, with tradeoffs called out
2. You pick one (or ask for a mix)
3. Builds a **low-fidelity Figma exploration** — grayscale, structural, fast
   - Section named: `[Flow Name — Platform — Concept N]`
4. Screenshots and presents it — iterate up to 2 rounds
5. You lock a direction — it's saved to memory before moving on

Lo-fi is intentional. The goal is structure and flow, not polish. Polish happens in `/pd:design`.

### Component gaps

When a screen needs a component that doesn't exist in your design system, the agent doesn't block:

1. Logs the gap to `component-gaps.md`
2. Asks: build it now (triggers `ds-plan` → `ds-build`) or use a placeholder and continue
3. If built now: the new component is added to your design system and the screen is completed
4. If placeholder: a labeled frame holds the spot and the gap is tracked for batch resolution

### Annotations

After screens are designed, `/pd:annotate` adds behavioral context next to each screen (60px gap):

```
question: "How would you like annotations?"
[Custom annotation component]   [Figma native annotations]
```

If no annotation component exists in your design system, the agent builds one.

Each annotation covers: interactions, states, validation rules, empty states, navigation targets, and edge cases.

### Handoff output

`/pd:handoff` produces two things:

**Figma handoff page** — annotated screens organized by flow, with a cover frame showing project name, version, and date.

**Markdown spec doc** (`design-system/projects/<slug>/handoff/<slug>-handoff.md`) — contains:
- Screen-by-screen purpose, states, and component map
- Numbered logic and behavior (from annotations)
- Acceptance criteria (testable, specific)
- Navigation and routing table
- Component gaps and their resolution status
- Design tokens used
- Open questions for engineering

### Context resilience

Every phase writes a checkpoint to `active_session.md`. After any `/clear`:

```
/pd:resume
```

The agent reads the checkpoint, shows where you left off, and continues from the next incomplete step — no re-explaining needed.

Project memory lives in `design-system/projects/<slug>/` and persists indefinitely across sessions.

---

## Commands Reference

### Design System

#### `/ds-init`
Bootstrap scan of your Figma file. Auto-triggered on first session if the knowledge-base is empty.

Scans all variable collections, components, text styles, color styles, and effect styles. Detects alias chain architecture and token mode semantics.

**When to use:** First-time setup, or after a major redesign.

---

#### `/ds-update`
Re-scan Figma and show what changed since the last scan. Computes a semantic diff and requires confirmation before writing.

---

#### `/ds-audit`
System-wide compliance check of all built components against your discovered conventions.

---

#### `/design-system-designer` ← component work starts here
The unified component agent. Handles new components, visual changes, structural variants, and theme work.

**Also triggers on:** "build a [component]", "restyle the [component]", "add a [variant] to [component]", "change the theme", "add dark mode"

---

#### `/ds-build`
Build a single component from a spec. Called by `/design-system-designer` internally, available directly for power users.

---

#### `/ds-add-variant`
Add a variant or state to an existing component.

---

#### `/ds-plan`
Interactive planning interview that produces a confirmed build spec consumed by `/ds-build`.

---

#### `/ds-verify`
Screenshot-based visual verification of a component against its build spec.

---

#### `/ds-spec`
Generate an engineering implementation spec — props, variants, token mapping, accessibility, usage examples.

**Output:** `design-system/memory/specs/<ComponentName>-engineering.md`

---

#### `/ds-doc`
Generate Figma-based documentation for a component.

---

#### `/ds-handoff`
Create tickets in Jira or Linear for component handoff to engineering.

<div align="center">

```
   ▄███████████▄
  █  ◠       ◠  █── ノ
  █      ▿      █
   ▀███████████▀
      ▄█████▄   ──›

  Packaged up and shipped!  ✦
```

</div>

---

#### `/ds-token`
Find the right token for a design intent without building anything.

**Usage:** "What token should I use for a card background?" → returns a match, candidates, or logs a gap.

---

#### `/ds-feedback`
Capture workflow preferences. Tell DDD how you like to work — saved to `feedback_*.md` and applied by every skill.

---

#### `/ds-memory`
View and manage persistent memory — registry, token gaps, decisions, conventions log, session state.

---

#### `/ds-help`
Show current system status and all available commands.

---

### Product Design

#### `/product-designer` ← product work starts here
The unified product design agent. Infers your intent and routes to the right phase.

**Also triggers on:** "start a new project", "design the [flow/screen]", "concept the [screen]", "create handoff", "where are we"

---

#### `/pd:new-project`
Initialize a new product design project. Ingests or writes a project brief.

---

#### `/pd:discover`
Discovery phase — research synthesis, problem framing, design challenge statement.

---

#### `/pd:define`
Define phase — user flows, IA, screen inventory, concept queue.

---

#### `/pd:concept`
Concept phase — 3 written directions, lo-fi Figma exploration, iterate, lock.

---

#### `/pd:design`
Design phase — hi-fi screens built with your design system components.

---

#### `/pd:annotate`
Annotate screens with interaction logic, states, and edge cases.

---

#### `/pd:handoff`
Generate Figma handoff page and markdown spec document.

---

#### `/pd:status`
Project dashboard — phase progress, screen count, gaps, and what's next.

---

#### `/pd:resume`
Resume an in-progress project after a context reset.

---

### Updates

#### `/ddd-update`
Upgrade DDD skills to the latest version without touching your knowledge-base.

**What it does:**
1. Shows your current installed version vs. the latest
2. Runs `npx design-driven-development@latest .`
3. Confirms the version stamp changed
4. Syncs `agent_version` in `config.md`

Your `design-system/` knowledge-base, tokens, components, memory, and projects are **never touched** — only the skill files in `.claude/skills/` are refreshed.

**Version nudge:** At the start of each session, DDD checks npm for a newer version. If one exists:

```
🔔 DDD v0.x.x is available (installed: v0.2.0). Run /ddd-update to upgrade your skills.
```

---

## Project Structure

```
your-project/
├── design-system/
│   ├── config.md                    # Figma file key, UI kit, tracker, agent version
│   ├── MEMORY.md                    # Dashboard: counts, recent activity
│   ├── framework.md                 # System overview (auto-generated by /ds-init)
│   ├── knowledge-base/              # Read-only — written by /ds-init and /ds-update only
│   │   ├── components.md            # All components: variants, properties, children
│   │   ├── tokens.md                # All variable collections grouped by category/mode
│   │   ├── styles.md                # Text, color, and effect styles
│   │   ├── conventions.md           # Inferred naming and structure patterns
│   │   └── theming-conventions.md   # Alias chain rules and mode semantics (if detected)
│   ├── memory/                      # Claude-managed — updated throughout sessions
│   │   ├── REGISTRY.md              # Per-component build status and history
│   │   ├── TOKEN-GAPS.md            # Tokens Claude needed but didn't find
│   │   ├── active_session.md        # In-progress session checkpoint (resume after /clear)
│   │   ├── DECISIONS-ARCHIVE.md
│   │   ├── CONVENTIONS-LOG.md
│   │   ├── AUDIT-LOG.md
│   │   ├── feedback_*.md            # Saved workflow preferences
│   │   └── specs/                   # Build specs and engineering specs per component
│   └── projects/                    # Product Designer — one folder per project
│       ├── PROJECTS.md              # All projects: name, phase, status
│       └── <project-slug>/
│           ├── brief.md             # Project brief (ingested or written)
│           ├── research.md          # Discovery notes and design challenge
│           ├── flows.md             # User flows and IA
│           ├── screen-inventory.md  # All screens: status, figma node, flow
│           ├── directions.md        # Locked concept directions per item
│           ├── component-gaps.md    # Missing DS components and resolution status
│           ├── active_session.md    # Phase checkpoint (resume after /clear)
│           └── handoff/
│               └── <slug>-handoff.md  # Markdown spec doc for engineering
└── .claude/
    ├── skills/                      # All DDD skill files (overwritten on update)
    │   └── .ddd-version             # Installed version stamp
    ├── hooks/
    │   └── ddd-version-check.sh     # SessionStart hook for update nudge
    └── settings.json                # SessionStart hook registered here
```

> **`knowledge-base/`** is read-only during normal operation. Only `/ds-init` and `/ds-update` write to it.
>
> **`memory/`** is Claude-managed — read and written freely during sessions.
>
> **`projects/`** is Product Designer memory — persists indefinitely, one folder per project.
>
> **`active_session.md`** exists in both `memory/` (component work) and `projects/<slug>/` (product work). Both survive a `/clear` and power the resume flow.

---

## Agent Rules

These rules are injected into every Claude session via `CLAUDE.md`:

**Token boundary** — Claude only uses tokens present in `tokens.md`. If no suitable token exists, it logs the gap to `TOKEN-GAPS.md` and waits for your confirmation.

**Alias chain enforcement** — Semantic variables are alias pointers. Claude will never write a raw hex value onto a semantic token.

**Explore before implementing** — Any request to change how a component looks triggers an exploration phase before the real component is touched.

**Inspect before modifying** — Existing strokes, effects, and fills are read and documented before any modification.

**Concepts before hi-fi** — Product design work gets 3 written directions and a lo-fi exploration before any final screen is built.

**Ambiguity** — If anything is unclear, Claude outputs a numbered question list before taking any Figma action.

**Hard stops** — Claude will not apply an unconfirmed token, will not contradict a convention without approval, and will not modify an existing component unless explicitly asked.

**Context resilience** — Both agents checkpoint progress after every phase. After any `/clear`, use `/design-system-designer` or `/pd:resume` to pick up exactly where you left off.

---

## Uninstall

```bash
npx design-driven-development uninstall /path/to/your/project
```

Removes all skill files from `.claude/skills/`, the version-check hook from `.claude/hooks/`, the hook entry from `.claude/settings.json`, and the DDD section from `CLAUDE.md`.

Your `design-system/` directory is preserved — delete it manually if you no longer need it:

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

Within a single project, the Product Designer can manage multiple product design projects simultaneously — each with its own brief, flows, screens, and handoff doc under `design-system/projects/`.

---

<div align="center">

```
   ▄███████████▄
  █  ◉       ◉  █────✦
  █      ▿      █
   ▀███████████▀
      ▄█████▄
```

*v0.2.0 — Built for [Claude Code](https://claude.com/claude-code)*

</div>
