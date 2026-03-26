---
name: ds-update
description: >
  Re-scan the Figma file and refresh the knowledge-base with changes. Use when the user
  types /ds-update, asks to "sync", "refresh", "rescan", or when the Figma file has been
  updated and the knowledge-base needs to reflect changes.
---

# Update Design System

Re-scan the Figma file and show what changed since the last scan.

## Procedure

### Step 1 — Load current state
Read `design-system/memory/feedback_*.md` if any exist and apply entries tagged `all` or `ds-update`.

Read:
- `design-system/config.md` — get Figma file key and agent version
- `design-system/knowledge-base/tokens.md` — current token state
- `design-system/knowledge-base/components.md` — current component state
- `design-system/knowledge-base/styles.md` — current style state

### Step 2 — Check agent version
Compare `config.md` agent_version against `VERSION` in the agent repo.
If different:
- Note the version change
- Check if any schema migrations are needed (for now, assume backward-compatible)
- Update version in config.md

### Step 3 — Re-scan Figma
Run the same scans as ds-init:
- `figma_get_variables` → new token state
- `figma_search_components` + `figma_get_component_details` → new component state
- `figma_get_styles` → new style state

  If `figma_get_styles` returns zero styles (sync API throws on dynamic-page documents), fall back to `figma_execute`:
  ```javascript
  const [textStyles, paintStyles, effectStyles] = await Promise.all([
    figma.getLocalTextStylesAsync(),
    figma.getLocalPaintStylesAsync(),
    figma.getLocalEffectStylesAsync(),
  ]);
  return JSON.stringify({
    text: textStyles.map(s => ({ id: s.id, name: s.name, fontSize: s.fontSize, fontFamily: s.fontName?.family, fontWeight: s.fontName?.style })),
    paint: paintStyles.map(s => ({ id: s.id, name: s.name })),
    effect: effectStyles.map(s => ({ id: s.id, name: s.name, effects: s.effects })),
  });
  ```

### Step 4 — Compute semantic diff
Compare old vs. new state for each knowledge-base file:

**Tokens:**
- New tokens added
- Tokens removed
- Token values changed (note which modes)
- New collections or modes added

**Components:**
- New components added
- Components removed
- Variants/properties changed on existing components
- Children changed (composition changes)
- Handle renames: if a component disappeared and a new one appeared with similar
  structure/properties, flag as potential rename

**Styles:**
- New styles added
- Styles removed
- Style values changed

### Step 5 — Present diff

```
## Design System Update — Changes Detected

### Tokens (<N> changes)
- **Added:** <list>
- **Removed:** <list>
- **Changed:** <list with old → new values>

### Components (<N> changes)
- **Added:** <list>
- **Removed:** <list>
- **Modified:** <list with what changed>
- **Possible renames:** <list>

### Styles (<N> changes)
- **Added:** <list>
- **Removed:** <list>
- **Changed:** <list>

### No changes
<list categories with no changes>
```

If no changes detected: "Knowledge-base is up to date."

### Step 6 — Confirm and write
Ask user to confirm before writing:
> Apply these changes to the knowledge-base? (yes/no)
> Or apply selectively? I can update tokens only, components only, etc.

On confirmation:
1. Write updated knowledge-base files
2. Update `framework.md` if structural changes detected
3. Re-infer conventions if naming patterns changed
4. Update `MEMORY.md` with new counts and activity log

### Step 7 — Write back
Invoke write-memory to update MEMORY.md.

## Rules
- NEVER overwrite knowledge-base without showing the diff first
- NEVER overwrite without user confirmation
- If the scan returns drastically different results (>50% change), warn the user —
  this might indicate scanning the wrong file or a major restructure
- Preserve any user annotations in knowledge-base files (lines starting with `<!-- user: `)
