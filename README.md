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
| [Figma Console MCP](https://github.com/anthropics/figma-console-mcp) | Must be connected in Claude Code |
| A Figma file with a UI kit | shadcn, Radix, Material, or custom |

---

## Installation

```bash
cd your-project
npx design-driven-development
```

No clone required. The package downloads, installs into your project, and is discarded. Your project is fully self-contained.

What gets installed:

```
your-project/
├── design-system/          ← knowledge-base, memory, config
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

## The `/ds-designer` Agent

The primary way to work with DDD. A unified agent that handles all component building, restyling, and theme work in a single conversational flow.

**You don't need to know which command to use.** Just describe what you want:

```
"Build me a tooltip component"
"Make the button look more elevated with shadows"
"Add a destructive variant to the alert"
"Change the brand color to indigo"
"Apply a dark mode to the system"
```

### How it classifies your intent

`/ds-designer` (or any of the phrases above) identifies what kind of work you need, then routes to the right workflow:

| What you say | Route |
|---|---|
| "build", "create", "I need a", "new [component]" | **New component** — spec → token audit → build → verify |
| "make it look", "restyle", "redesign", "[adjective]-ify" | **Visual change** — explore concepts → token audit → implement |
| "add a [state]", "add a variant", "add hover/disabled" | **Structural variant** — token audit → add to component set |
| "change the theme", "brand color", "dark mode" | **Theme change** — alias chain enforcement → primitives → semantics |

If your request is ambiguous, it asks one question with a native picker — no open-ended text needed.

### Workflow: Visual / style change

When you ask to *change how a component looks*, the agent never jumps straight to implementation. It runs an exploration phase first:

1. **Inspect** — reads the component's current fills, strokes, and effects before touching anything. Gradient strokes and bound effect styles are preserved.
2. **Explore** — builds 3–4 concept frames on a temporary `Exploration - <ComponentName>` page in Figma. Screenshots each direction and presents them.
3. **You pick** — a native question widget presents the concepts. Implementation doesn't start until you make an explicit choice.
4. **Token audit** — maps every visual property of the chosen direction to existing tokens. Lists gaps and waits for your confirmation before creating anything new.
5. **Implement** — applies the chosen direction using variable bindings only. Never writes raw hex values.
6. **Verify** — screenshots the final result, checks against the spec.

### Workflow: Theme change

When you want to change colors, apply a new theme, or add a dark mode:

1. **Load alias rules** — reads `theming-conventions.md` to understand your token architecture. Detects which collections are primitives vs. semantic aliases, and which modes are mutable vs. read-only.
2. **Plan** — shows every primitive and alias that will change before touching anything. Reference modes (e.g., `shadcn`, `shadcn-dark`) are flagged as read-only and never modified.
3. **Execute** — adds new primitives to the raw color collection first, then updates semantic variables as `VARIABLE_ALIAS` references. **Never writes raw hex onto semantic tokens.**
4. **Validate** — screenshots affected components to confirm the theme propagated correctly.

### Session checkpoints

For complex work, `/ds-designer` writes progress to `design-system/memory/active_session.md` after each phase. If you need to `/clear` context mid-exploration, your work isn't lost — the agent reads the checkpoint on the next session and offers to resume:

```
Found an in-progress session: visual change on Button.
Exploration is complete — you chose Concept B.
Resume from token audit, or start fresh?
[Resume]  [Start fresh]
```

---

## Commands

### Scanning & Knowledge-Base

#### `/ds-init`
Bootstrap scan of your Figma file. Auto-triggered on first session if the knowledge-base is empty.

**What it does:**
- Scans all variable collections, components, text styles, color styles, and effect styles
- Falls back to async Figma APIs on dynamic-page documents (never silently drops styles)
- Detects alias chain architecture — if your semantic tokens reference primitives via `VARIABLE_ALIAS`, documents this as a hard constraint in `theming-conventions.md`
- Classifies each token mode as **brand** (mutable, safe to customize) or **reference** (read-only, do not modify)
- Reads documentation/about pages in your Figma file and incorporates theming instructions
- Infers naming conventions and assigns confidence levels — asks you to confirm anything ambiguous

**When to use:** First time setting up a project, or after a major redesign that changed your token/component structure.

---

#### `/ds-update`
Re-scan Figma and show what changed since the last scan.

**What it does:**
- Runs the same scans as `/ds-init` (with async fallback for styles)
- Computes a semantic diff: tokens added/removed/changed, components added/removed/modified, styles changed
- Flags potential renames (component disappeared, similar one appeared)
- Requires your confirmation before writing — shows the full diff first
- Never overwrites user annotations in knowledge-base files

**When to use:** After making changes in Figma (new components, updated tokens, new styles).

---

#### `/ds-audit`
System-wide compliance check of all built components against your discovered conventions.

**When to use:** Before a release, or when onboarding new team members to verify consistency.

---

### Building & Editing

#### `/ds-designer` ← start here
The unified agent. Handles new components, visual changes, structural variants, and theme work. See [The `/ds-designer` Agent](#the-ds-designer-agent) above for full details.

**Natural language triggers** (no slash command needed):
- "build a [component]", "I need a [component]", "create a [component]"
- "make the [component] look [adjective]", "restyle the [component]", "redesign the [component]"
- "add a [state/variant] to [component]"
- "change the theme", "add dark mode", "change the brand color"

---

#### `/ds-build`
Build a single component in Figma from a spec. Called by `/ds-designer` internally, but available directly for power users.

**What it does:**
1. Loads or creates a build spec for the component
2. Runs a token audit — lists every visual property, checks coverage, surfaces gaps before building
3. Creates the component inside a Section/Frame (never on blank canvas)
4. Binds all visual properties as variable references — never raw hex values
5. Sets up variant structure if specified
6. Screenshots and verifies the result (up to 3 iterations)
7. Runs post-build validation checklist

**Rules:**
- Requires a build spec (runs a condensed planning interview if none exists)
- All style bindings use async Figma setters (`setStrokeStyleIdAsync`, `setEffectStyleIdAsync`)
- Gaps are surfaced and confirmed before any tokens are created

---

#### `/ds-add-variant`
Add a variant or state to an existing component. Called by `/ds-designer` internally, but available directly.

**What it does — for structural variants** (new property value, boolean state):
1. Identifies target component and verifies it in Figma
2. Inspects current state — reads fills, strokes, effects before any modification
3. Runs token audit for the new variant's visual properties
4. Duplicates an appropriate existing variant, renames per conventions, binds tokens
5. Screenshots the full component set with the new variant

**What it does — for visual/style changes** (anything that changes how a component looks):
1. Classifies the request as visual before proceeding
2. Runs the full exploration phase (concept frames, screenshot, user picks)
3. Inspects and preserves existing gradient strokes and bound effect styles
4. Token audit before implementation
5. Implements with variable bindings only

---

#### `/ds-verify`
Screenshot-based visual verification of a component against its build spec.

**When to use:** After building, or to spot-check an existing component.

---

### Documentation & Handoff

#### `/ds-spec`
Generate an engineering implementation spec for a component — props, variants, token mapping, accessibility, usage examples.

**Output:** `design-system/memory/specs/<ComponentName>-engineering.md`

---

#### `/ds-doc`
Generate Figma-based documentation for a component — intended for design system documentation sites or Figma annotations.

---

#### `/ds-handoff`
Create tickets in your configured tracker (Jira or Linear) for component handoff to engineering. Pulls data from the build spec and engineering spec.

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

### Utilities

#### `/ds-token`
Find the right token for a design intent without building anything.

**Usage:** "What token should I use for a card background?" or "Which token covers disabled text?"

Returns a high-confidence match, a list of candidates if ambiguous, or logs a gap to `TOKEN-GAPS.md` if nothing fits.

---

#### `/ds-feedback`
Capture workflow preferences outside of a build session. Tell DDD how you like to work and it will remember across all future sessions.

**Examples:**
- "Take screenshots more frequently during builds"
- "Always ask before creating new tokens"
- "Use kebab-case for all new component names"

Preferences are written to `design-system/memory/feedback_*.md` and applied automatically by every skill.

---

#### `/ds-memory`
View and manage persistent memory files — registry, token gaps, decisions, conventions log, and active session state.

---

#### `/ds-help`
Show current system status and all available commands. Includes component count, token count, last scan date, and any pending token gaps.

---

### Updates

#### `/ddd-update`
Upgrade DDD skills to the latest version without touching your knowledge-base.

**Triggers:** `/ddd-update`, "update DDD", "upgrade DDD", or automatically when the version nudge appears.

**What it does:**
1. Shows your current installed version vs. the latest
2. Runs `npx design-driven-development@latest .`
3. Confirms the version stamp changed
4. Syncs `agent_version` in `config.md`

Your `design-system/` knowledge-base, tokens, components, memory, and config are **never touched** by an update — only the skill files in `.claude/skills/` are refreshed.

**Version nudge:** At the start of each session, DDD checks npm for a newer version. If one exists, you'll see:

```
🔔 DDD v0.x.x is available (installed: v0.2.0). Run /ddd-update to upgrade your skills.
```

The check uses a 2-second timeout and fails silently if you're offline.

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
│   └── memory/                      # Claude-managed — updated throughout sessions
│       ├── REGISTRY.md              # Per-component build status and history
│       ├── TOKEN-GAPS.md            # Tokens Claude needed but didn't find
│       ├── active_session.md        # In-progress session checkpoint (resume after /clear)
│       ├── DECISIONS-ARCHIVE.md
│       ├── CONVENTIONS-LOG.md
│       ├── AUDIT-LOG.md
│       ├── feedback_*.md            # Saved workflow preferences
│       └── specs/                   # Build specs and engineering specs per component
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
> **`active_session.md`** is written automatically during complex workflows so progress survives a `/clear`. Delete it manually if you want to discard an in-progress session.

---

## Agent Rules

These rules are injected into every Claude session via `CLAUDE.md`:

**Token boundary** — Claude only uses tokens present in `tokens.md`. If no suitable token exists, it logs the gap to `TOKEN-GAPS.md` and waits for your confirmation before proceeding.

**Alias chain enforcement** — If `theming-conventions.md` exists, Claude treats semantic variables as alias pointers. It will never write a raw hex value onto a semantic token — gaps are surfaced, the correct primitive-first workflow is followed.

**Explore before implementing** — Any request to change how a component looks triggers an exploration phase with concept frames before the real component is touched.

**Inspect before modifying** — Existing strokes, effects, and fills are read and documented before any modification. Gradient strokes and named effect styles are preserved unless you explicitly ask to replace them.

**Ambiguity** — If anything is unclear (which token, which component, how to interpret a design intent), Claude outputs a numbered question list before taking any Figma action.

**Hard stops** — Claude will not apply an unconfirmed token, will not contradict a convention without approval, and will not modify an existing component unless explicitly asked.

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
