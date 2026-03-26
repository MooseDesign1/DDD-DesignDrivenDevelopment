---
name: pd-screen-builder
description: >
  Internal skill for building one hi-fi screen in Figma using the design system.
  Called by pd-design for each screen in the inventory. Handles component resolution,
  token binding, and gap detection. Never invoked directly by the user.
---

# Screen Builder

Build one hi-fi screen in Figma. Resolves components, binds tokens, and flags gaps.

---

## Inputs (passed from pd-design)

- `screen_name` — display name of the screen
- `screen_purpose` — one-line description of what this screen does
- `flow_name` — which flow this belongs to
- `platform` — mobile, desktop, tablet
- `direction` — locked concept direction description
- `parent_section` — Figma section node to place the screen in

---

## Step 1 — Determine frame size

| Platform | Default Size |
|----------|-------------|
| Mobile (iOS) | 375 × 812 |
| Mobile (Android) | 360 × 800 |
| Desktop | 1440 × 900 |
| Tablet | 768 × 1024 |
| Responsive web | 1440 × 900 (desktop) + 375 × 812 (mobile) |

Create frame inside parent section:
```javascript
const frame = figma.createFrame();
frame.name = '<Screen Name> — <Platform>';
frame.resize(<width>, <height>);
// position inside section
```

---

## Step 2 — Identify required components

Based on the screen purpose and direction, list every component needed:
- Navigation (nav bar, tab bar, breadcrumb)
- Layout containers (cards, panels, sections)
- Form elements (inputs, dropdowns, checkboxes)
- Content components (lists, tables, media)
- Action elements (buttons, FABs, links)
- Feedback components (toasts, banners, modals)
- Empty/error/loading states

For each, invoke resolve-component:
- **Use** → instantiate existing component
- **Add-variant** → note, build variant after screen if critical
- **Compose** → build from existing components
- **Build-new** → invoke pd-gap-report, use placeholder

---

## Step 3 — Layout structure

Build the screen frame using auto-layout:
```javascript
frame.layoutMode = 'VERTICAL';
frame.primaryAxisSizingMode = 'FIXED';
frame.counterAxisSizingMode = 'FIXED';
frame.itemSpacing = <spacing token value>;
frame.paddingTop = <token>;
frame.paddingBottom = <token>;
frame.paddingLeft = <token>;
frame.paddingRight = <token>;
```

Add structural layers in order (top to bottom for mobile, as appropriate for desktop):
1. Status bar / nav bar
2. Header / hero
3. Main content area
4. Action bar / bottom nav (if applicable)

---

## Step 4 — Populate content

For each component in the layout:
- **Existing component** → `figma_search_components` → instantiate → set appropriate variant
- **Text content** → use realistic placeholder copy (not "Lorem ipsum" — use actual labels like "Your donations", "Continue", "Invalid email")
- **Images / media** → use a rectangle frame labeled with the content type ("User photo", "Product image")

Bind all tokens:
- Invoke resolve-token for each fill, stroke, spacing, and typography property
- Use `setBoundVariable` for variable bindings
- Use `await node.setStrokeStyleIdAsync(id)` and `await node.setEffectStyleIdAsync(id)` for styles
- **Never apply raw hex/RGBA**

---

## Step 5 — Gap detection

For any component that returned `build-new` from resolve-component:
1. Invoke pd-gap-report with: component name, screen name, required properties
2. Insert a placeholder frame:
   ```javascript
   const placeholder = figma.createFrame();
   placeholder.name = 'TODO: <ComponentName>';
   placeholder.fills = [{ type: 'SOLID', color: { r: 1, g: 0.9, b: 0.4 }, opacity: 0.3 }];
   // Add text label "Missing component: <name>"
   ```
3. Return gap details to pd-design for handling decision.

---

## Step 6 — Return result

Return to pd-design:
```
{
  frame_node_id: "<id>",
  screen_name: "<name>",
  status: "complete" | "has-gaps" | "has-placeholders",
  gaps: ["<component1>", "<component2>"],  // if any
  token_bindings: <count>,
}
```

---

## Rules

- **Never skip token binding** — all visual properties must be bound. No exceptions.
- **Realistic content** — use actual copy and labels, not lorem ipsum
- **Auto-layout always** — no absolute positioning unless absolutely necessary
- **Text nodes** — always `textAutoResize = 'HEIGHT'` + `resize(width, 1)`
- **Gaps are non-blocking** — log and continue, don't halt the screen build
- **Screenshot is handled by pd-design** — this skill does not screenshot
