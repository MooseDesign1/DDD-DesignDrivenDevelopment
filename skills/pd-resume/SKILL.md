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

Read `projects/<slug>/active_session.md`.

If no `active_session.md` exists or `status: complete` → tell user:
> "No in-progress session found. Use `/pd:status` to see your projects or `/pd:new-project` to start one."

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

- Never restart a phase from scratch on resume — always skip to the last incomplete step
- If the checkpoint references a Figma node that no longer exists → warn and ask user to re-identify the node
- If multiple projects are in-progress → ask which one to resume before loading checkpoint
