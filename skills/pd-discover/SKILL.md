---
name: pd-discover
description: >
  Discovery phase of product design. Use when the user types /pd:discover,
  asks to "research", "ideate", "understand the problem", "explore user needs",
  or wants to do problem framing before defining flows. Synthesizes insights
  and frames the design challenge.
---

# Discover

Research, ideation, and problem framing. The first diamond of Double Diamond.

---

## Step 1 — Load context

Read:
- `projects/<slug>/brief.md` — project brief
- `projects/<slug>/active_session.md` — current phase and checkpoint
- `projects/PROJECTS.md` — identify active project slug

If no active project is found, tell the user:
> "No active project found. Run `/pd:new-project` to start one."

Update `active_session.md`:
```markdown
phase: DISCOVER
status: in_progress
```

---

## Step 2 — Discovery interview

Ask the user to share any existing knowledge. Take one topic at a time.

**2a — User research**
Ask:
> "Do you have any user research, interviews, analytics, or feedback to inform this design? (Share links, paste notes, or describe — skip if not yet available)"

If shared → extract themes, pain points, and user needs. Summarize into `research.md`.
If skipped → note "no research available — assumptions to be validated".

**2b — Competitive or reference review**
Ask:
> "Are there any products, apps, or references that do something similar — either to learn from or differentiate against?"

If shared → read URLs or descriptions. Note what works, what doesn't, what to borrow, what to avoid.

**2c — Business and product context**
Ask:
> "Any business constraints, brand rules, or product decisions already locked in that will affect the design?"

Capture: mandatory patterns, must-avoid patterns, tech constraints, existing components to reuse.

---

## Step 3 — Synthesize and frame

Based on brief + discovery inputs, write a design challenge statement:

```
## Design Challenge

**We are designing for:** <primary user>
**Who needs to:** <core action or goal>
**Because:** <underlying motivation>
**The challenge is:** <friction, gap, or constraint>
**We'll know we succeeded when:** <measurable outcome or behavior change>
```

Present to user. Ask:
```
question: "Does this capture the right design challenge?"
options:
  - "Yes — this is the right frame"
  - "Adjust it — let me clarify something"
```

Iterate until confirmed.

---

## Step 4 — Design principles (optional)

Ask:
```
question: "Do you want to define 2–3 design principles to guide decisions throughout this project?"
options:
  - "Yes — let's define them"
  - "No — skip for now"
```

If yes → ask for principles or suggest based on the challenge (e.g., "Progressive disclosure", "Mobile-first clarity", "Trust through transparency"). User confirms.

---

## Step 5 — Write research.md

Write `projects/<slug>/research.md`:
```markdown
# Research & Discovery: <Project Name>

> Phase: Discover
> Date: <date>

## Design Challenge
<challenge statement>

## User Insights
<synthesized themes from research — or "No research yet — assumptions to validate">

## Competitive Review
<what was reviewed and key takeaways — or "Not reviewed">

## Constraints
<locked-in product/business constraints>

## Design Principles
<principles — or "Not defined">
```

---

## Step 6 — Checkpoint

Update `active_session.md`:
```markdown
### Discover
status: complete
challenge: <one-line challenge statement>
principles: <count or "none">
research_source: <description>
```

Invoke pd-write-memory.

---

## Step 7 — What's next

```
────────────────────────────────────────
✅  Discovery complete

Research saved to projects/<slug>/research.md

**What's next:** /pd:define — Map out user flows and build your screen inventory

Or:
/pd:status        — See project overview
/product-designer — Continue with a different task
────────────────────────────────────────
```
