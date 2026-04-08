# Design System Config

## Project
- agent_version: 0.2.2
- figma_file_key: kIxQQH9eSn0Wn2faDBGyj8
- figma_file_url: https://www.figma.com/design/kIxQQH9eSn0Wn2faDBGyj8/Design-system---Claude-orchestrate
- ui_kit: shadcn/ui
- tracker: none

## Preferences

## Custom Rules

### Component Edit Workflow — Exploration First

When the user asks to edit, update, or redesign a component's visual style (e.g. "make it look 3D", "change the style", "redesign the button"):

1. **EXPLORE before touching the component.** Build 3–4 concept frames in Figma showing distinct directions. Present screenshots. Do NOT modify the real component set yet.
2. **Iterate on user feedback.** The user may point to their own mockup or request a variant of a concept. Explore that variant alongside the original.
3. **Wait for the user to finalize.** Only proceed when the user explicitly picks a direction (e.g. "I want this one", "implement this").
4. **Gap analysis before implementation.** Once a direction is finalized:
   a. Audit existing tokens in `knowledge-base/tokens.md` against what the design needs.
   b. Identify any missing raw primitives or semantic tokens.
   c. Check for needed Figma paint styles (gradients, textures) or effect styles (shadow sets).
   d. Clearly list gaps and ask the user to confirm before creating tokens/styles.
5. **Implement with variable bindings only.** Never apply raw hex values to component fills, strokes, or effects. Always bind to token variables via `boundVariables`. Create Figma styles for gradients and shadow sets, then bind those style IDs.

**Hard stop:** If implementation would require using raw hex values because a token doesn't exist → stop, create the token first, get user confirmation, then proceed.

---

### Figma Exploration Frame Rules

When creating concept/exploration frames in Figma:

- Always set parent card frames to `primaryAxisSizingMode = 'AUTO'` and `counterAxisSizingMode = 'FIXED'` (or AUTO) — never fixed height unless intentional.
- For all text nodes inside exploration cards: set `textAutoResize = 'HEIGHT'`, then call `resize(width, 1)` to let the height auto-expand. This prevents text from collapsing into surrounding elements.
- Place all exploration frames inside a Section or named parent Frame so they don't float on the canvas.

---

### Token-First Implementation Rule

Before modifying any component:
1. Read `knowledge-base/tokens.md` in full.
2. Map every color, border, shadow, and spacing need to an existing token.
3. For anything without a matching token: propose a name + intent, log to `memory/TOKEN-GAPS.md`, and wait for user confirmation before creating.
4. For gradient strokes: create a named Figma paint style (e.g. `Button/Primary/stroke-sheen`) and apply via `setStrokeStyleIdAsync`.
5. For shadow sets: create a named Figma effect style (e.g. `Button/Primary/shadow-3d`) and apply via `setEffectStyleIdAsync`.
6. Use `node.setStrokeStyleIdAsync(id)` and `node.setEffectStyleIdAsync(id)` — never the synchronous `strokeStyleId =` setter (dynamic-page runtime restriction).
