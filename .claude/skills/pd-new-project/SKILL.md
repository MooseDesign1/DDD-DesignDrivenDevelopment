---
name: pd-new-project
model: sonnet-4-6
description: >
  Start a new product design project. Use when the user types /pd:new-project,
  says "start a new project", "I have a brief", "I want to design [product]",
  or needs to initialize a project before any design work begins.
  Creates project memory, ingests or writes a brief, and opens the discovery phase.
---

# New Project

Initialize a product design project: ingest or write a brief, create project memory, and open discovery.

---

## Step 1 — Load context

Read `projects/PROJECTS.md` if it exists. Note any existing projects.

---

## Step 2 — Brief intake

Use AskUserQuestion:
```
question: "Do you have a project brief or PRD ready?"
options:
  - "Yes — I have a brief or PRD"
  - "No — help me write one"
```

### If YES — ingest brief

Ask freeform (inline, not AskUserQuestion):
> "Paste the link(s) — one per line. I support Notion, Confluence, Google Docs, Figma, or any URL. You can share multiple documents."

**Also scan reactively:** if the user already pasted URLs earlier in the conversation, treat those as provided documents without asking again.

Fetch all URLs in parallel. Also handle:
- **Pasted content** → use as-is
- **Figma link** → use figma_get_metadata and figma_get_design_context
- **Local file path** → read the file

**Preserve, don't summarize.** For each document, extract and organize the content into the brief.md source section (see Step 4). Do not compress or paraphrase — keep the substance.

**Run coverage assessment** against these areas:

| Area | Status |
|------|--------|
| Product / what it is | ✓ / ⚠ / ✗ |
| Target user | ✓ / ⚠ / ✗ |
| Core problem | ✓ / ⚠ / ✗ |
| Key flows | ✓ / ⚠ / ✗ |
| Platforms | ✓ / ⚠ / ✗ |
| Constraints | ✓ / ⚠ / ✗ |
| Success metrics | ✓ / ⚠ / ✗ |

Show the coverage table inline. Then ask **only about gaps (✗ or ⚠)**:
- Use AskUserQuestion for structured gaps where options make sense
- Use freeform inline questions for open-ended gaps
- Never re-ask what the documents already answered

If two documents conflict on the same area, surface it explicitly:
> "⚠ Conflict: [Doc A] says X, [Doc B] says Y — which should we use?"

If zero gaps → skip directly to Step 3.

### If NO — write brief together

Tell the user:
> "I'll ask a series of questions to understand what you're building and write a structured project brief. Answer as much or as little as you know — we can refine as we go."

Ask one at a time:
1. **What is this product or feature?** — name, one-line pitch
2. **Who is the primary user?** — role, context, level of tech-savviness
3. **What problem are you solving?** — the core pain or unmet need
4. **What are the main things users need to do?** — list the key flows (e.g., sign up, browse, checkout)
5. **What platforms?** — web, iOS, Android, tablet, all?
6. **Any constraints?** — must use existing design system, specific tech stack, deadline, brand rules
7. **How will you know it's successful?** — metric, behavior, or outcome

Compile into brief format, present to user, confirm.

---

## Step 3 — Project slug and naming

Ask:
```
question: "What should we call this project? (Used as the folder and reference name)"
options:
  - "[Suggested: <slugified-product-name>]"
  - "Let me type a different name"
```

Slugify the name: lowercase, hyphens, no spaces. E.g., `donor-portal`, `checkout-redesign`.

---

## Step 4 — Initialize project memory

Create the following files:

**`projects/<slug>/brief.md`**
```markdown
# Project Brief: <Project Name>

> Created: <date>
> Status: discovery

## Product
<product description>

## Target User
<user description>

## Problem
<problem statement>

## Key Flows
- <flow 1>
- <flow 2>
- ...

## Platforms
<platforms>

## Constraints
<constraints>

## Success Metrics
<metrics>

## Annotation Preference
<!-- Set during pd-annotate: "native" or "custom" -->
pending

## Source Documents

### [Document Title or URL 1]
> Source: <URL or "written in session">
> Fetched: <date>

<preserved content from document — not summarized>

---

### [Document Title or URL 2]  *(if multiple)*
> Source: <URL>
> Fetched: <date>

<preserved content from document>

---
```

**`projects/<slug>/design/screen-inventory.md`**
```markdown
# Screen Inventory: <Project Name>

> Auto-populated by /pd:define. Updated throughout the project.

| Screen | Flow | Platform | Status | Figma Node | Notes |
|--------|------|----------|--------|------------|-------|
```

**`projects/<slug>/design/component-gaps.md`**
```markdown
# Component Gaps: <Project Name>

> Components needed for this project that aren't in the design system.
> Resolved gaps trigger ds-plan → ds-build.

| Component | Screen | Properties Needed | Status | Date |
|-----------|--------|-------------------|--------|------|
```

**`projects/<slug>/design/directions.md`**
```markdown
# Directions: <Project Name>

> Concept directions explored and chosen per flow/screen/component.

| Item | Concepts Explored | Chosen Direction | Rationale | Date |
|------|-------------------|------------------|-----------|------|
```

**`projects/<slug>/design/active_session.md`**
```markdown
# Active Session

agent: product-designer
project: <slug>
phase: DISCOVER
current_item:
figma_page:
status: in_progress
session_started: <date>

## Phases
### Init
status: complete
brief_source: <"written in session" | list of document URLs>
```

Update `projects/PROJECTS.md`:
- Add row: `| <Project Name> | <slug> | DISCOVER | in_progress | <date> |`

---

## Step 5 — What's next

```
────────────────────────────────────────
✅  Project initialized: <Project Name>

Brief saved to projects/<slug>/brief.md

────────────────────────────────────────
```

**▶ What's Next**

`/pd:discover` — Research, ideation, and problem framing

*Just say "do it", "continue", or "yes" to start — no need to type the command*

Or jump ahead to:
- `/pd:define` — Skip straight to mapping user flows
- `/pd:status` — See this project's overview
