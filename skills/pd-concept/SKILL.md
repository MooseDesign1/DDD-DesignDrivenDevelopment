---
name: pd-concept
description: >
  Concept phase of product design. Use when the user types /pd:concept,
  asks to "explore directions", "concept the screens", "ideate visually",
  "show me options", or wants to explore design directions before committing
  to final screens. Produces 3 written directions, then low-fidelity Figma
  explorations for user sign-off.
---

# Concept

Explore design directions: 3 written concepts per item → user picks one → low-fi Figma → iterate → lock direction.

---

## Step 1 — Load context

Read:
- `projects/<slug>/brief.md`
- `projects/<slug>/flows.md`
- `projects/<slug>/directions.md`
- `projects/<slug>/active_session.md` — check for concept queue and last completed item
- `design-system/knowledge-base/components.md` — available components for reference
- `design-system/knowledge-base/tokens.md` — tokens for lo-fi reference

If `active_session.md` has a `concept_queue` with items remaining, resume from the next unfinished item.
If no queue exists, prompt the user to run `/pd:define` first or define the queue inline.

Update `active_session.md`:
```markdown
phase: CONCEPT
status: in_progress
```

---

## Step 2 — Confirm concept queue

Show the current concept queue. Ask:
```
question: "Ready to start concepting? Here's the queue:"
options:
  - "Yes — start with [first item]"
  - "Reorder the queue first"
  - "Add something to the queue"
  - "Skip concepting — I'll design manually in Figma"
```

If "Skip" → update directions.md with "Manual concept — skipped", mark phase complete, show What's Next.

---

## Step 3 — For each item in the queue

Repeat Steps 3a–3g for each queue item.

### 3a — Write 3 concept directions

Generate 3 distinct written directions. Each direction should:
- Have a short name (1–3 words, e.g., "Progressive Disclosure", "Card-First", "Minimal Linear")
- Describe the core UX pattern and visual approach in 2–4 sentences
- Note what makes it distinct from the others
- Flag any tradeoffs or risks

Example format:
```
**Concept 1 — Progressive Disclosure**
Surfaces only the essential field first (email), then reveals additional fields as the user advances. Reduces initial cognitive load and improves mobile completion rates. Risk: multiple steps may feel slow for users who want to complete quickly.

**Concept 2 — Single-Screen Summary**
All fields visible upfront in a compact card layout. Users can scan everything at once and fill in any order. Risk: can feel overwhelming on mobile; requires strong visual hierarchy.

**Concept 3 — Guided Wizard**
Step-by-step modal flow with large type and a single CTA per step. Visual progress indicator keeps users oriented. Risk: highest step count; may frustrate returning users who know what they want.
```

Ask:
```
question: "Which direction do you want to explore in Figma?"
options:
  - "Concept 1 — [name]"
  - "Concept 2 — [name]"
  - "Concept 3 — [name]"
  - "Mix elements from two concepts"
  - "None of these — describe a different direction"
```

If "Mix" or "None" → clarify, write a hybrid concept direction, confirm.

### 3b — Create Figma exploration page

Check if the concepts page exists:
```javascript
await figma.loadAllPagesAsync();
let page = figma.root.children.find(p => p.name === 'PDA — <Project Name> — Concepts');
if (!page) {
  page = figma.createPage();
  page.name = 'PDA — <Project Name> — Concepts';
}
figma.currentPage = page;
```

### 3c — Create a section for this concept item

Section naming: `[<Flow Name> — <Platform> — Concept <N>]`
Example: `[Donor Flow — Mobile — Concept 1]`

```javascript
const section = figma.createSection();
section.name = '[<Flow Name> — <Platform> — Concept <N>]';
// Position after last section on the page
```

### 3d — Build lo-fi screens inside the section

**Lo-fi fidelity rules:**
- Grayscale only — no color tokens applied yet
- Placeholder text ("Label", "Description", "Button") — no real copy
- Basic shapes for images and media (rectangle with X through it)
- No icons — use labeled rectangles ("icon")
- Auto-layout for structure — spacing from DS spacing tokens only (no color)
- Real component instances where they exist — instantiate them in their default/neutral variant

For each screen in this flow item:
1. Create a frame at the appropriate device size (375×812 for mobile, 1440×900 for desktop)
2. Build the layout per the chosen concept direction
3. Use `figma_search_components` to find and instantiate existing DS components
4. Label structural areas clearly (e.g., "Nav", "Hero", "Form", "CTA")

**Auto-layout rules:**
- Frame: `primaryAxisSizingMode = 'AUTO'`, `counterAxisSizingMode = 'FIXED'`
- All text nodes: `textAutoResize = 'HEIGHT'`, then `resize(width, 1)`
- Never set fixed heights on frames containing auto-layout content

### 3e — Screenshot and present

`figma_take_screenshot` — capture the section.

Present with:
- Screenshot of lo-fi screens
- Reminder: "This is low-fidelity — the goal is structure and flow, not visual polish."
- Note what's working and what's open to feedback

Ask:
```
question: "How does this direction feel?"
options:
  - "This works — lock this direction"
  - "Close, but I want to adjust [something]"
  - "Start over with a different concept"
```

### 3f — Iterate (max 2 rounds)

If "Adjust" → ask what to change, apply, re-screenshot. Max 2 iteration rounds.
If "Start over" → go back to Step 3a, present a different concept.
If "Lock" → proceed to 3g.

### 3g — Lock direction and log

Update `projects/<slug>/directions.md`:
```
| <Item> | Concept 1: <name>, Concept 2: <name>, Concept 3: <name> | <Chosen concept name> | <One line rationale> | <date> |
```

Update `active_session.md` — mark item as complete, advance queue to next item.

---

## Step 4 — Queue complete

When all queue items are done:

Update `active_session.md`:
```markdown
### Concept
status: complete
items_concepted: <n>
```

Invoke pd-write-memory.

---

## Step 5 — What's next

```
────────────────────────────────────────
✅  Concept phase complete

<n> directions locked across <n> flows/screens.

All lo-fi explorations on Figma page: "PDA — <Project Name> — Concepts"

**What's next:** /pd:design — Build final hi-fi screens using your design system

Or:
/pd:status        — See full project overview
/product-designer — Continue with a different task
────────────────────────────────────────
```

---

## Rules

- **Lo-fi only** — no color, no detailed typography, no polish. Speed and structure are the goals.
- **Always write 3 directions first** — never go straight to Figma without written concepts.
- **Never touch real production screens** — concepts live on the dedicated Concepts page only.
- **Section naming is strict** — `[Flow Name — Platform — Concept N]` with square brackets.
- **Max 2 iteration rounds per item** — if user still isn't happy after 2 rounds, suggest a fresh concept.
- **Respect the queue** — always checkpoint after each item so context reset doesn't lose progress.
