---
name: ds-token
description: >
  Standalone token resolution — find the right token for a design intent. Use when
  the user types /ds-token, asks "which token should I use for...", "what token
  covers...", or has any question about token selection. Invokes the resolve-token
  internal skill.
---

# Resolve Token

Find the right token for a design intent.

## Procedure

### Step 1 — Understand the need
If the user hasn't specified clearly, ask:
- What is the design intent? (e.g., "background for a card", "spacing between form fields")
- What context? (e.g., which component, which state)

### Step 2 — Invoke resolve-token
Call the resolve-token internal skill with the design intent.

### Step 3 — Present result

**If high confidence match:**
> Token: `<token-name>` — <value>
> This is the <category> token used for <intent description>.

**If medium confidence (multiple candidates):**
> I found a few candidates:
> 1. `<token-1>` — <value> — <why it might fit>
> 2. `<token-2>` — <value> — <why it might fit>
> Which one fits your intent?

**If no match (gap):**
> No existing token covers this need. I've logged a gap:
> - **Need:** <description>
> - **Suggested name:** `<suggested-token>`
> - **Logged to:** design-system/memory/TOKEN-GAPS.md
>
> Once you add this token to the system, run `/ds-update` to refresh.

### Step 4 — Write back
Invoke write-memory if any gaps were logged.

## Rules
- Never suggest tokens that aren't in knowledge-base/tokens.md
- If modes exist, mention which mode the value corresponds to
