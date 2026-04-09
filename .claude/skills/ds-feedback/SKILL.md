---
name: ds-feedback
model: haiku
effort: low
description: >
  Capture workflow preferences and corrections outside of a build session. Use when
  the user types /ds-feedback, wants to adjust how a skill behaves, or provides
  guidance about the design system workflow.
---

# Capture Feedback

Record a workflow preference or correction.

## Procedure

### Step 1 — Understand the feedback
Ask if not clear:
1. **Which skill or workflow?** (build, plan, token, doc, handoff, general, etc.)
2. **What should change?** (the correction or preference)
3. **Why?** (context helps apply the feedback correctly in future)

### Step 2 — Classify
Determine if this is:
- **A preference** → update `design-system/config.md` under Preferences or Custom Rules
- **A correction** → create/update `design-system/memory/feedback_<topic>.md`
- **Both** → do both

### Step 3 — Write

**For config.md preferences:**
Read config.md, add the preference under the appropriate section, write back.

**For feedback files:**
Create or update `design-system/memory/feedback_<descriptive-name>.md`:

```markdown
---
name: <descriptive name>
type: feedback
date: <YYYY-MM-DD>
---

<The rule or correction>

**Why:** <reason from user>
**Applies to:** <which skill(s) or situations>
```

### Step 4 — Confirm
Show what was saved and where:
> Saved feedback: "<summary>"
> - Written to: `design-system/memory/feedback_<name>.md`
> - Updated config.md: <if applicable>

### Step 5 — Write back
Invoke write-memory to update MEMORY.md.

## Rules
- Check for existing feedback files on the same topic before creating new ones
- If an existing feedback file covers the same area, update it rather than duplicating
- Keep feedback files focused — one topic per file
