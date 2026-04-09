---
name: exec-map
model: opus
effort: high
description: >
  Map an existing codebase into structured reference docs. Use when the user types
  /exec:map, says "map the codebase", "scan the project", "map the code",
  "generate architecture docs", or wants to prepare a codebase for the executor.
  Thin wrapper around exec-code-mapper.
---

# Exec Map

Scan a codebase and produce reference documentation for the executor sub-agents.

**Effort level: medium.**

---

## Step 1 — Identify project

Read `projects/PROJECTS.md` if it exists.

If one active project → use it.
If multiple → use AskUserQuestion to pick one.
If none → use AskUserQuestion:
```
question: "No project found. What would you like to map?"
options:
  - "Map the current directory"
  - "Let me specify a path"
  - "Create a project first with /plan:project"
```

If mapping without a project, use a temporary slug based on the directory name.
Reference docs go to `projects/<slug>/dev/`.

---

## Step 2 — Check for existing reference docs

Check if `projects/<slug>/dev/architecture.md` exists.

If exists → use AskUserQuestion:
```
question: "Reference docs already exist (mapped on <date>). What do you want to do?"
options:
  - "Refresh — re-scan and overwrite"
  - "Keep existing — no changes needed"
  - "Show me what's there first"
```

If "Show me" → present summary of existing docs, then re-ask.

---

## Step 3 — Invoke exec-code-mapper

Delegate to exec-code-mapper with the project slug and codebase root.

---

## Step 4 — Present results

Show the summary from exec-code-mapper:
```
--------------------------------------------
  Codebase mapped: <Project Name>
  
  Reference docs created:
    • dev/architecture.md — stack, patterns, conventions
    • dev/api-map.md — <n> API routes
    • dev/component-map.md — <n> components
    • dev/db-schema.md — <n> tables
  
  Ready for: /exec:feature to build features
--------------------------------------------
```

---

## Rules

- **Re-runnable** — mapping again overwrites existing docs (it's a refresh)
- **Works without a project** — can map any directory, creates temp slug
- **Read-only scan** — never modifies source code
