---
name: build-frame
description: >
  Internal skill for creating Figma frames with auto-layout, sizing, spacing, and padding.
  Called by ds-build and ds-add-variant. Handles frame creation, auto-layout setup, and
  child node placement. Uses tool routing from config.md figma_mcp setting.
---

# Build Frame

Create a Figma frame with auto-layout configuration.

## Procedure

### Step 1 — Receive frame spec from calling skill
Expected input:
- name: frame name
- width/height: dimensions (or "hug" / "fill")
- direction: "horizontal" | "vertical"
- padding: top, right, bottom, left (as token references or pixel values)
- gap: spacing between children (as token reference or pixel value)
- children: ordered list of child nodes to create/place

### Step 2 — Resolve tokens
For any padding or gap specified as a token reference, invoke resolve-token
to get the pixel value.

### Step 3 — Create frame via figma_execute

```javascript
const frame = figma.createFrame();
frame.name = "<name>";
frame.layoutMode = "<HORIZONTAL|VERTICAL>";
frame.primaryAxisSizingMode = "<FIXED|AUTO>";
frame.counterAxisSizingMode = "<FIXED|AUTO>";
frame.paddingTop = <value>;
frame.paddingRight = <value>;
frame.paddingBottom = <value>;
frame.paddingLeft = <value>;
frame.itemSpacing = <gap>;

// If fixed dimensions
frame.resize(<width>, <height>);

// Set fills if specified
frame.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }];
```

### Step 4 — Place children
For each child in the spec, create or move nodes into the frame.

### Step 5 — Bind variables
For any token-backed values, bind the Figma variables:

```javascript
// Only if variable binding is available and token maps to a Figma variable
const variable = await figma.variables.getVariableByIdAsync("<variableId>");
frame.setBoundVariable("<property>", variable);
```

### Step 6 — Return
Return the frame node ID to the calling skill.

## Rules
- Always use "fill container" for child sizing unless the spec explicitly says "hug contents"
- Check frame dimensions after creation — if something looks wrong, report before continuing
- Never set raw spacing numbers if a token is available — always bind to the token
