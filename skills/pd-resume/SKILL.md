---
name: pd-resume
description: >
  Resume an in-progress product design project after a context reset. Use when the user
  types /pd:resume, says "resume", "continue the project", "pick up where we left off",
  or when the product-designer dispatcher detects an in-progress session on startup.
---

# Resume

Restore project context from memory and continue from the last checkpoint.

---

## Step 1 — Load checkpoint

Read `DDD/projects/PROJECTS.md`. Find sessions: look for `DDD/projects/*/design/active_session.md`.

**Case A — In-progress session found** (status: in_progress) → continue to Step 2.

**Case B — No session or all complete** → continue to Step 1b.

If multiple in-progress sessions → ask which one to resume.

---

## Step 1b — Intelligent next step detection

No active design session. Scan all active projects to find what needs the product designer next.

For each project in PROJECTS.md, read in parallel:
- `DDD/projects/<slug>/plan/master-plan.md`
- List files in `DDD/projects/<slug>/design/`
- List files in `DDD/projects/<slug>/handoff/`

Then identify what phase each feature needs:

**Needs DISCOVER or DEFINE** — feature in master-plan.md tagged `needs-design` with no files in `design/` yet. Not started.

**Needs CONCEPT** — brief/define doc exists in `design/` but no concept doc. Start concepting.

**Needs DESIGN (hi-fi)** — concept is locked (`design/<feature>-concept.md` exists, direction chosen) but no Figma screens yet.

**Needs ANNOTATE** — Figma screens exist but no annotation doc in `design/`.

**Needs HANDOFF** — annotated screens exist but no `handoff/<feature>-handoff.md` yet. Blocking the executor.

**Already handed off** — `handoff/<feature>-handoff.md` exists. No action needed from designer.

Present:

```
────────────────────────────────────────────
  No active design session. Here's what needs the designer:

  NEEDS HANDOFF (blocking executor):
  • <project> / <feature> — annotated, handoff not done yet

  NEEDS ANNOTATION:
  • <project> / <feature> — screens done, not annotated

  NEEDS DESIGN (hi-fi):
  • <project> / <feature> — concept locked, no screens yet

  NEEDS CONCEPT:
  • <project> / <feature> — define done, not concepted

  NOT STARTED:
  • <project> / <feature> — needs-design, no work begun
────────────────────────────────────────────
```

Use AskUserQuestion:
```
question: "What would you like to work on?"
options:
  - "Handoff <top blocking feature>"
  - "Annotate <next annotation feature>"
  - "Design <next hi-fi feature>"
  - "Start a new feature from scratch"
  - "Show full design status — /pd:status"
```

If user picks a feature → invoke the appropriate phase skill for it. Do NOT stall.

---

## Step 2 — Show checkpoint summary

Present what was saved:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Resuming: <Project Name>
  Phase:    <phase>
  Last step: <last completed phase block>
  Current:  <current_item or current_screen>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Ask:
```
question: "Ready to continue?"
options:
  - "Yes — pick up from [last step]"
  - "Jump to a different phase"
  - "Show full project status first"
```

---

## Step 3 — Route to correct phase skill

Based on `phase` in `active_session.md`:

| Phase | Route to |
|-------|---------|
| DISCOVER | pd-discover |
| DEFINE | pd-define |
| CONCEPT | pd-concept |
| DESIGN | pd-design |
| ANNOTATE | pd-annotate |
| HANDOFF | pd-handoff |

Pass the checkpoint context (current item, queue state, figma page) so the phase skill can skip already-completed steps.

---

## Rules

- **Never stall** — if no active session, scan the project state and surface what phase each feature needs next
- Never restart a phase from scratch on resume — always skip to the last incomplete step
- Prioritize handoff gaps — a feature blocked on handoff is blocking the entire executor pipeline
- If the checkpoint references a Figma node that no longer exists → warn and ask user to re-identify the node
- If multiple projects are in-progress → ask which one to resume before loading checkpoint
