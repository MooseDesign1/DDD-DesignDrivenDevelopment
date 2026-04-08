# Conventions Log

> Evolving decisions about naming, structure, and patterns.

## Decisions
| Decision | Rationale | Date |
|----------|-----------|------|
| Explore-first before component edits | Jumping straight to implementation caused wasted work and a full revert. User needs to see options and iterate before the real component is touched. | 2026-03-25 |
| Token-first implementation (no raw hex) | First implementation of 3D button used raw hex values. Had to revert all 32 components. Always audit tokens, create gaps, get confirmation, then implement with variable bindings. | 2026-03-25 |
| Preserve existing stroke type when enhancing | Original Primary button had a GRADIENT_LINEAR stroke (white sheen). Enhancement replaced it with a flat solid border — wrong. Must inspect existing stroke type and preserve it as a Figma paint style. | 2026-03-25 |
| Text nodes in exploration frames need AUTO height | Fixed-height text nodes collapsed into buttons in concept frames. Always set `textAutoResize = 'HEIGHT'` + `resize(w, 1)` and ensure parent uses `primaryAxisSizingMode = 'AUTO'`. | 2026-03-25 |
| Use `setStrokeStyleIdAsync` / `setEffectStyleIdAsync` | Synchronous `strokeStyleId =` and `effectStyleId =` throw in dynamic-page mode. Must use async setters. | 2026-03-25 |
| Component-specific semantic tokens for component-level colors | Button border light + depth wall colors are specific to Button. Created `button/primary-border` and `button/primary-depth` as semantic tokens aliasing raw primitives, rather than binding directly to raw colors. | 2026-03-25 |
