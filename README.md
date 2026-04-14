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

**A Claude Code plugin that connects design thinking to working code.**

Four agents. One pipeline. Brief in — shipped product out.

![Version](https://img.shields.io/badge/version-0.2.3-A259FF?style=flat-square)
![Claude Code](https://img.shields.io/badge/Claude_Code-required-0ACF83?style=flat-square)
![Figma](https://img.shields.io/badge/Figma_MCP-required-1ABCFE?style=flat-square)

</div>

---

## The Pipeline

DDD gives Claude four specialized agents that hand off to each other across the full product lifecycle:

```
  PLAN              DESIGN            BUILD
  ────              ──────            ─────

  Planner      →    Product      →    Executor
  ────────          Designer          ────────
  Brief             ────────          Architect
  Phases            Discovery         Backend
  Features          Definition        Frontend
  Execution         Concepts          Verifier
  bundles           Hi-fi screens
                    Annotations             ↑
                    Handoff            DS Designer
                                       ────────────
                                       Components
                                       Tokens
                                       Themes
```

Each agent owns its own memory. They never write to each other's directories — they communicate through handoff files that the next agent reads.

---

## How It Works

DDD installs into any Claude Code project. Each session it:

1. **Reads** `design-system/config.md` and `design-system/MEMORY.md` to orient itself
2. **Checks** if the knowledge-base is populated — if not, auto-runs `/ds-init`
3. **Routes** your natural language to the right agent — no commands required
4. **Loads** only the files needed for the active command, on demand
5. **Enforces** boundaries — agents never overwrite each other's work

You never have to know which command to run. Just describe what you want.

---

## Requirements

| Requirement | Notes |
|---|---|
| [Claude Code](https://claude.com/claude-code) | CLI v1.0+ |
| A Figma MCP | One of the two options below — DDD auto-detects on first run |
| A Figma file with a UI kit | shadcn, Radix, Material, or custom |

---

## Figma MCP Setup

DDD needs a Figma MCP to read and write to your Figma files. Two options are supported — pick one, or use both with a configurable default.

### Option A — Figma Console MCP ✅ Extensively tested

Open-source, runs locally. Requires the Figma Console plugin running in your Figma desktop app.

**Setup:** Follow the guide at [github.com/southleft/figma-console-mcp](https://github.com/southleft/figma-console-mcp)

### Option B — Official Figma MCP

Figma's native MCP, remote-hosted. Requires a Figma desktop app connection and an Organization or Professional plan for write tools.

**Setup:** Follow the guide at [developers.figma.com/docs/figma-mcp-server](https://developers.figma.com/docs/figma-mcp-server)

> [!WARNING]
> **The official Figma MCP write tools have not been tested with DDD.** DDD was built and validated against the Figma Console MCP, which has undergone extensive testing. The official MCP's `use_figma` tool is theoretically equivalent to `figma_execute`, but real-world behaviour with DDD's build pipeline (component creation, token binding, variant assembly) has not been verified. Use at your own risk and report any issues.

### Auto-detection

On first run, DDD probes both MCPs automatically and writes the result to `design-system/config.md`. No manual configuration needed. If both are connected, it defaults to Figma Console MCP and lets you change the default in config.

---

## Installation

```bash
cd /your-project
npx design-driven-development@latest
```

No clone required. The package downloads, installs into your project, and is discarded.

What gets installed:

```
your-project/
├── design-system/          ← DS knowledge-base, memory, config
├── projects/               ← Planner, PD, and executor memory (one folder per project)
├── .claude/
│   ├── skills/             ← all DDD skill files
│   ├── hooks/              ← version-check hook (runs on session startup)
│   └── settings.json       ← SessionStart hook registered here
└── CLAUDE.md               ← DDD context + intent router injected into every session
```

**To update**, re-run from inside your project:

```bash
cd your-project
npx design-driven-development
```

Or from inside a Claude session: say **"update DDD"** or run `/ddd-update`. Your knowledge-base and memory are never touched — only skill files are refreshed.

---

## The Four Agents

### 1. Planner

**What it does:** Breaks a product into phases, features, and execution bundles. Orchestrates handoffs between the other agents.

**Invoke with:**
```
/planner
```
Or just say:
```
"I have a brief for a new product"
"Plan out the MVP"
"Break this into phases and features"
"What features are ready to build?"
"Detail the login feature for execution"
```

**Workflow:**
```
Brief → Master plan (phases + features) → Per-feature execution bundles → Gate detection
```

After design handoff is complete, the planner runs **Pass 2** on each feature — enriching it into a self-contained execution bundle that the executor reads to build DS gaps → backend → frontend with human checkpoints.

---

### 2. Product Designer

**What it does:** Takes a product from brief to fully designed, annotated, and development-ready flows in Figma.

**Invoke with:**
```
/product-designer
```
Or just say:
```
"Design the onboarding flow"
"Concept the dashboard"
"We need hi-fi screens for checkout"
"Create the dev handoff"
"Where are we on the donor portal design?"
```

**Workflow (Double Diamond):**
```
DISCOVER          DEFINE            DEVELOP           DELIVER
────────          ──────            ───────           ───────
Brief ingest  →   User flows    →   Concepts      →   Hi-fi screens
Research &        IA mapping        Lo-fi Figma       Annotations
ideation          Screen            Direction         Handoff doc
                  inventory         selection
```

Each phase has a dedicated command, or let `/product-designer` infer where you are and route automatically.

---

### 3. DS Designer

**What it does:** Builds, restyls, and themes individual components in your Figma design system.

**Invoke with:**
```
/ds-designer
```
Or just say:
```
"Build me a tooltip component"
"Add a destructive variant to the alert"
"Restyle the card to feel more elevated"
"Apply a dark mode to the system"
"Change the brand color to indigo"
```

The DS Designer never jumps straight to implementation — it always explores, audits tokens, and confirms before touching real components.

---

### 4. Executor

**What it does:** Reads execution bundles from the planner and builds them stage-by-stage using specialized sub-agents (architect, backend, frontend, verifier). Never writes code directly.

**Invoke with:**
```
/executor
```
Or just say:
```
"Build the login feature"
"Execute the dashboard bundle"
"Map the codebase"
"What's been built so far?"
"Resume the build"
```

**Workflow:**
```
Execution bundle → Codebase map → DS gaps → Backend → Frontend → Verifier → Done
```

Each stage ends with a human checkpoint. A verifier runs after every task. If something breaks — you know before moving on.

---

## Natural Language Routing

You don't need to know which agent to call. Claude's intent router maps your words to the right agent automatically. When it's ambiguous between two agents, it asks one question with quick-pick options — no open-ended typing.

| You say | Agent |
|---------|-------|
| "I have a brief", "plan this out", "roadmap" | Planner |
| "design the [flow]", "hi-fi screens", "concept", "handoff" | Product Designer |
| "build this feature", "implement", "dev status", "map the codebase" | Executor |
| "build a [component]", "restyle", "add variant", "change theme" | DS Designer |

---

## First Run

On first launch, Claude auto-detects your Figma MCP, then scans your design system.

```bash
cd your-project
claude
```

**Step 1 — MCP detection (automatic)**

Claude probes both MCPs silently and writes the result to `design-system/config.md`. If neither is connected, it shows setup links and waits.

**Step 2 — Knowledge-base scan (`/ds-init`)**

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
| `memory/REGISTRY.md` | Component registry with build status |

---

## Commands Reference

### Planner

| Command | What it does |
|---------|--------------|
| `/planner` | Main dispatcher — routes by intent |
| `/plan:project` | Brief → phases → features → master plan |
| `/plan:feature` | Pass 1: task breakdown. Pass 2: full execution bundle after design handoff |
| `/plan:status` | Dashboard with gate auto-detection (design done? DS gaps resolved? backend complete?) |
| `/plan:resume` | Resume after context reset |

---

### Product Designer

| Command | Phase | What happens |
|---------|-------|--------------|
| `/product-designer` | Any | Unified agent — infers phase and routes |
| `/pd:new-project` | Init | Ingest or write a project brief, initialize memory |
| `/pd:discover` | Discover | Research synthesis, problem framing |
| `/pd:define` | Define | User flows, IA, screen inventory, concept queue |
| `/pd:concept` | Develop | 3 written directions → lo-fi Figma → iterate → lock |
| `/pd:design` | Deliver | Hi-fi screens built with your design system |
| `/pd:annotate` | Deliver | Logic and behavior annotations next to each screen |
| `/pd:handoff` | Deliver | Figma handoff page + markdown spec document |
| `/pd:status` | Any | Project dashboard |
| `/pd:resume` | Any | Resume after context reset |

---

### DS Designer

| Command | What it does |
|---------|--------------|
| `/ds-designer` | Unified component agent — builds, restyls, adds variants, applies themes |
| `/ds-init` | Bootstrap scan of your Figma file |
| `/ds-update` | Re-scan and show what changed |
| `/ds-audit` | System-wide compliance check against your conventions |
| `/ds-build` | Build a single component from a confirmed spec |
| `/ds-add-variant` | Add a variant or state to an existing component |
| `/ds-plan` | Interactive planning interview → build spec |
| `/ds-verify` | Screenshot-based visual verification |
| `/ds-spec` | Engineering implementation spec with props, tokens, and accessibility |
| `/ds-doc` | Figma-based component documentation |
| `/ds-handoff` | Create Jira / Linear tickets for component handoff |
| `/ds-token` | Find the right token for a design intent |
| `/ds-feedback` | Capture workflow preferences |
| `/ds-memory` | View and manage persistent memory |
| `/ds-help` | System status and all available commands |

---

### Executor

| Command | What it does |
|---------|--------------|
| `/executor` | Main dispatcher — routes by intent |
| `/exec:feature` | Build a feature from its execution bundle |
| `/exec:map` | Map an existing codebase into reference docs |
| `/exec:resume` | Resume after context reset |

---

### Updates

| Command | What it does |
|---------|--------------|
| `/ddd-update` | Upgrade skill files to the latest version |

---

## Project Structure

```
your-project/
├── design-system/
│   ├── config.md                    # Figma file key, UI kit, tracker, agent version
│   ├── MEMORY.md                    # Dashboard: counts, recent activity
│   ├── framework.md                 # System overview (auto-generated by /ds-init)
│   ├── knowledge-base/              # Read-only — written by /ds-init and /ds-update only
│   │   ├── components.md
│   │   ├── tokens.md
│   │   ├── styles.md
│   │   └── conventions.md
│   └── memory/                      # DS Designer memory
│       ├── REGISTRY.md
│       ├── TOKEN-GAPS.md
│       ├── active_session.md
│       ├── feedback_*.md
│       └── specs/
│
└── projects/                        # Shared project index + per-project memory
    ├── PROJECTS.md                  # All projects: name, phase, status
    └── <project-slug>/
        ├── brief.md                 # Project brief (shared by planner + PD)
        │
        ├── design/                  # Product Designer memory
        │   ├── screen-inventory.md
        │   ├── component-gaps.md
        │   ├── directions.md
        │   ├── flows.md
        │   └── active_session.md
        │
        ├── handoff/                 # Product Designer output → executor reads this
        │   └── <slug>-handoff.md
        │
        ├── plan/                    # Planner memory
        │   ├── master-plan.md
        │   ├── active_session.md
        │   └── features/
        │       └── <feature>.md    # Execution bundle (Pass 2)
        │
        └── dev/                     # Executor memory
            ├── architecture.md
            ├── api-map.md
            ├── component-map.md
            ├── db-schema.md
            ├── status.md
            └── active_session.md
```

**Ownership rules:**
- `design-system/` → DS Designer only
- `projects/<slug>/design/` and `handoff/` → Product Designer only
- `projects/<slug>/plan/` → Planner only
- `projects/<slug>/dev/` → Executor only
- `projects/PROJECTS.md` → all agents read it; Planner, PD, and Executor update it
- Agents may **read** other agents' directories for gate detection — they never write to them

---

## Agent Rules

**Token boundary** — DS Designer only uses tokens in `tokens.md`. If no suitable token exists, it logs the gap and waits for confirmation.

**Alias chain enforcement** — Semantic variables are alias pointers. Raw hex values are never written onto semantic tokens.

**Explore before implementing** — Any style change triggers an exploration phase before the real component is touched.

**Concepts before hi-fi** — Product design work gets 3 written directions and a lo-fi exploration before any final screen is built.

**Execution bundles** — Executor reads one file per feature. That file contains everything: design context, DS gap tasks, architecture decisions, backend tasks, frontend tasks, and human checkpoints.

**Gate auto-detection** — Planner reads the filesystem to detect when work is ready:
- Design done: `handoff/<feature>-handoff.md` exists
- DS gap resolved: `design/component-gaps.md` shows resolved
- Backend done: `dev/status.md` shows backend complete

**Ambiguity** — If anything is unclear, Claude asks a numbered question list before any Figma or code action.

**Context resilience** — Every agent checkpoints to `active_session.md` after each phase. After any `/clear`, use the agent's resume command or just describe where you are — it picks up automatically.

---

## Uninstall

```bash
npx design-driven-development uninstall /path/to/your/project
```

Removes skill files, version-check hook, hook entry from `settings.json`, and DDD sections from `CLAUDE.md`. Your `design-system/` and `projects/` directories are preserved — delete them manually if no longer needed.

---

## Multiple Projects

Each project gets its own memory under `projects/<slug>/`. Install DDD into as many repos as you need:

```bash
npx design-driven-development ~/projects/app-one
npx design-driven-development ~/projects/app-two
```

Within a single repo, the planner and product designer can manage multiple products simultaneously — each with its own brief, flows, plan, and dev status.

---

<div align="center">

```
   ▄███████████▄
  █  ◉       ◉  █────✦
  █      ▿      █
   ▀███████████▀
      ▄█████▄
```

*v0.2.3 — Built for [Claude Code](https://claude.com/claude-code)*

</div>
