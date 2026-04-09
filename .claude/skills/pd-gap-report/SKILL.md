---
name: pd-gap-report
model: haiku
effort: low
description: >
  Internal skill for logging a missing design system component discovered during
  screen building. Called by pd-screen-builder when resolve-component returns
  build-new. Logs the gap to component-gaps.md and optionally triggers ds-plan/ds-build.
  Never invoked directly by the user.
---

# Gap Report

Log a missing component and coordinate resolution.

---

## Inputs (passed from pd-screen-builder)

- `component_name` — what the component is called
- `screen_name` — which screen needs it
- `flow_name` — which flow the screen belongs to
- `properties_needed` — list of required properties/variants

---

## Step 1 — Check if gap already logged

Read `projects/<slug>/design/component-gaps.md`.
If the component is already listed → update the `screens` column to include the new screen. Do not duplicate.

---

## Step 2 — Log the gap

Append to `component-gaps.md`:
```
| <component_name> | <screen_name> | <properties_needed> | pending | <date> |
```

---

## Step 3 — Return to caller

Return to pd-screen-builder:
```
{
  gap_logged: true,
  component: "<name>",
  action: "placeholder"  // pd-design handles the build-now vs placeholder decision
}
```

---

## Step 4 — If resolution is triggered (build now)

When pd-design decides to resolve the gap immediately:

1. Invoke ds-plan with:
   - Component name
   - Purpose
   - Required variants and properties
   - Platform context

2. ds-plan produces a spec in `design-system/memory/specs/<ComponentName>.md`

3. Invoke ds-build to build the component in Figma

4. On completion:
   - Update `component-gaps.md`: set status to `resolved`
   - Update `design-system/knowledge-base/components.md` (ds-build handles this)
   - Return the new component node ID to pd-design

5. pd-design removes the placeholder and instantiates the built component.

---

## Rules

- Never block the screen build — log and return immediately
- If the same component is needed on multiple screens, log once with all screens listed
- Resolution is always triggered by pd-design, never auto-triggered by this skill
