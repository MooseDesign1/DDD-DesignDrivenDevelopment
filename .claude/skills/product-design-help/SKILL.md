---
name: product-design-help
description: >
  Explain the Product Designer Agent in depth. Triggered by /product-design-help,
  "how does the product designer work", "explain pd commands", "what is the product designer agent",
  "how do I start a project", "what are the design phases", "explain the design workflow",
  "how does pd work".
---

# Product Design Help

Explain the Product Designer Agent: what it does, the design phases, and when to use each command.

## Procedure

### Step 1 — Load state
Read `design-system/projects/PROJECTS.md` (skip if missing) to check for active projects.

### Step 2 — Present explanation

```
## Product Designer Agent

The Product Designer Agent runs end-to-end product design inside Figma — from an initial brief
through discovery, flows, concepts, hi-fi screens, annotations, and dev handoff.
All work is checkpointed so you can pause and resume across sessions.

---

### Design Phases

Each project moves through sequential phases. You can jump to any phase directly.

| Phase | Command | What happens |
|-------|---------|-------------|
| **Kick-off** | `/pd-new-project` | Capture brief, goals, users, constraints — creates project folder |
| **Discover** | `/pd-discover` | Research synthesis, problem framing, opportunity mapping |
| **Define** | `/pd-define` | User flows, information architecture, screen inventory |
| **Concept** | `/pd-concept` | 3–4 design directions explored as low-fi frames in Figma |
| **Design** | `/pd-design` | Hi-fi screens built using design system tokens and components |
| **Annotate** | `/pd-annotate` | Logic, interactions, and edge cases added to screens |
| **Handoff** | `/pd-handoff` | Dev handoff document generated in Figma |

---

### Commands

| Command | When to use |
|---------|------------|
| `/product-designer` | Main entry point — always start here. Detects active session and routes you. |
| `/pd-new-project` | Starting a brand new project from a brief |
| `/pd-discover` | When you have a project and want to do discovery work |
| `/pd-define` | When you're ready to map out flows and screens |
| `/pd-concept` | When you want to explore visual directions |
| `/pd-design` | When a direction is approved and you're building final screens |
| `/pd-annotate` | When screens are done and need interaction notes |
| `/pd-handoff` | When design is complete and ready for engineering |
| `/pd-status` | Check progress across all phases for the active project |
| `/pd-resume` | Resume exactly where you left off after a session break |

---

### How sessions work
- Each phase ends with a checkpoint saved to `design-system/memory/active_session.md`.
- Running `/product-designer` after a break detects the checkpoint and offers to resume.
- If context gets too long (>60% usage), the agent warns you — `/clear` then `/product-designer` to resume safely.
- All project files live in `design-system/projects/<project-slug>/`.

---

### Connection to the Design System
- The Product Designer reads your design system's tokens and components from `design-system/knowledge-base/`.
- If a screen requires a component that doesn't exist yet, the agent flags it as a gap.
- Resolve gaps with `/ds-plan` → `/ds-build`, then continue designing.
- Run `/ds-init` first if you haven't scanned your Figma file yet.

---

### Active projects
<if PROJECTS.md exists: list project name, current phase, and last updated for each project>
<if no projects exist: "No projects yet. Run `/pd-new-project` to start your first project.">
```

## Rules
- Fill in active projects from `design-system/projects/PROJECTS.md` if it exists
- If the file is missing or empty, show the "No projects yet" message
- Keep output scannable — tables as presented, no extra prose
