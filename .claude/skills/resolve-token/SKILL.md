---
name: resolve-token
model: haiku
effort: low
description: >
  Internal skill for matching a design intent to a token from the knowledge-base.
  Called by ds-token, ds-build, ds-plan, and ds-add-variant when a token need arises.
  Never invoked directly by the user.
---

# Resolve Token

Match a design intent (e.g., "background color for a card", "spacing between items")
to a specific token from `design-system/knowledge-base/tokens.md`.

## Procedure

### Step 1 — Load token reference
Read `design-system/knowledge-base/tokens.md`.

### Step 2 — Categorize the intent
Determine which token category the need falls into based on the knowledge-base structure.
Common categories include colors, spacing, radius, typography, effects — but use whatever
categories exist in the scanned tokens.

### Step 3 — Match

| Confidence | Action |
|-----------|--------|
| **High** — one token clearly fits the intent | Return the token name. Apply it. |
| **Medium** — 2-3 candidates could work | Present the candidates to the user with reasoning. Ask which to use. |
| **Low** — no token in the category fits | Suggest a token name and intent description. Log to `design-system/memory/TOKEN-GAPS.md`. Do NOT apply. |
| **None** — category doesn't exist in KB | Report that the token system doesn't cover this need. Log gap. |

### Step 4 — Return result
Return to calling skill:
- `{ match: "<token-name>", confidence: "high" }` — apply directly
- `{ candidates: [...], confidence: "medium" }` — needs user choice
- `{ gap: "<suggested-name>", intent: "<description>", confidence: "low" }` — logged, not applied

## Rules
- NEVER apply a token not present in knowledge-base/tokens.md
- NEVER invent or guess token names for application
- When modes exist (light/dark), note which mode the token resolves to
- A missing token does NOT block the whole build — flag it, skip it, continue
