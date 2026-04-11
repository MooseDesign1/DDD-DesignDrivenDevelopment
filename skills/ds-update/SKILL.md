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

**Variables — use `figma_execute` only (never `figma_get_variables`).**
`figma_get_variables` paginates and silently truncates results. Always fetch all variables
in a single JavaScript call:

```javascript
const collections = figma.variables.getLocalVariableCollections();
const allVars = figma.variables.getLocalVariables();

return JSON.stringify(collections.map(col => ({
  name: col.name,
  modes: col.modes,
  variables: allVars
    .filter(v => v.variableCollectionId === col.id)
    .map(v => ({
      name: v.name,
      valuesByMode: Object.fromEntries(
        col.modes.map(m => {
          const val = v.valuesByMode[m.modeId];
          if (val?.type === 'VARIABLE_ALIAS') {
            const ref = figma.variables.getVariableById(val.id);
            return [m.name, `alias:${ref?.name ?? val.id}`];
          }
          if (val?.r !== undefined) {
            return [m.name, `rgba(${Math.round(val.r*255)},${Math.round(val.g*255)},${Math.round(val.b*255)},${val.a?.toFixed(2)})`];
          }
          return [m.name, val];
        })
      )
    }))
})));
```

**Components and styles** — run in parallel:
- `figma_search_components` + `figma_get_component_details` → new component state
- `figma_get_styles` → new style state. If it returns zero styles (sync API throws on
  dynamic-page documents), fall back to `figma_execute`:
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

### Step 3b — Coverage check (abort if scan is incomplete)

Before any diffing, verify the scan is complete:

1. Count total variables in the fresh scan across all collections.
2. Count total variables currently tracked in `tokens.md`.
3. Verify every group name from `tokens.md` appears in the fresh scan.

**If either check fails — ABORT. Do not proceed to diff.**

```
Scan incomplete: knowledge-base tracks N variables but scan returned M.
Possible causes: Figma connection issue, wrong file, API truncation.
Aborting to prevent data loss. Re-run /ds-update or reconnect Figma.
```

Never silently treat a missing group as "no changes."

### Step 4 — Compute three-way semantic diff

For each category, compute three disjoint sets:

| Set | Logic | Label |
|-----|-------|-------|
| **Changed** | exists in KB and in scan, but value differs | `Changed:` |
| **Removed** | exists in KB but absent from fresh scan | `Removed:` |
| **Added** | exists in fresh scan but absent from KB | `Added:` |

Apply at two granularities for tokens:
- **Group level** — entirely new collection or group prefix (e.g., a new `chart/` group)
- **Token level** — new individual token within an existing group

**Tokens:**
- Added groups (new collection or prefix not in KB)
- Added tokens within existing groups
- Removed groups (in KB but absent from scan — after coverage check passed)
- Removed tokens within existing groups
- Changed token values (note which modes changed and old → new value)
- New collections or modes added

**Components:**
- Added components (in scan, not in KB)
- Removed components (in KB, not in scan)
- Modified: variants/properties changed on existing components
- Modified: children changed (composition changes)
- Possible renames: component disappeared and new one appeared with similar structure/properties

**Styles:**
- Added styles
- Removed styles
- Changed style values

### Step 5 — Present diff

```
## Design System Update — Changes Detected
Scan coverage: <N> variables fetched / <M> in KB ✓

### Tokens (<N> changes)
- **Added:** <list — include new groups and individual tokens>
- **Removed:** <list — include removed groups and individual tokens>
- **Changed:** <list with old → new values, noting which modes>

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

If no changes detected: "Knowledge-base is up to date. Scan: <N> variables verified."

Always show the scan coverage line so the user can confirm the scan was complete.

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
- **NEVER use `figma_get_variables`** — it paginates and silently truncates; always use `figma_execute` to fetch all variables in one call
- **NEVER diff with incomplete scan data** — if coverage check fails, abort immediately with a clear message
- **NEVER treat a missing group as unchanged** — absent groups are either Removed (if coverage passed) or scan failures (if coverage failed)
- **Diff is always three-way** — every category reports Added, Removed, and Changed; never just Changed
- **Show scan coverage on every run** — the count line lets the user verify completeness at a glance
- NEVER overwrite knowledge-base without showing the diff first
- NEVER overwrite without user confirmation
- If the scan returns drastically different results (>50% change), warn the user —
  this might indicate scanning the wrong file or a major restructure
- Preserve any user annotations in knowledge-base files (lines starting with `<!-- user: `)
