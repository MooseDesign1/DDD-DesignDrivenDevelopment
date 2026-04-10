---
name: exec-code-mapper
model: opus
effort: high
description: >
  Standalone codebase mapping agent. Scans an existing project codebase and produces
  structured reference docs (architecture.md, api-map.md, component-map.md, db-schema.md)
  under DDD/projects/<slug>/dev/. Called by exec-map (user-facing) or by exec-feature when
  no reference docs exist. Can also be invoked standalone for any codebase scan.
  Never invoked directly by the user — use /exec:map instead.
---

# Code Mapper

Scan a project codebase and produce structured reference documentation for the executor sub-agents.

**Effort level: medium.** Scan broadly, document concisely. Tables over prose.

---

## Step 1 — Identify project and codebase root

Read `DDD/projects/PROJECTS.md` if it exists. Identify the active project.

If the project has a `brief.md`, read it for tech stack hints.

Use AskUserQuestion:
```
question: "Where is the codebase root for this project?"
options:
  - "<detected path from brief or current working directory>"
  - "Let me specify a path"
  - "It's a monorepo — I'll point you to the right directory"
```

If monorepo → ask which subdirectory to scan.

---

## Step 2 — Framework and stack detection

Scan the codebase root for framework indicators:

1. **Package files:** `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, `pyproject.toml`
2. **Framework configs:** `next.config.*`, `nuxt.config.*`, `vite.config.*`, `tsconfig.json`, `tailwind.config.*`
3. **Database:** `supabase/`, `prisma/`, `drizzle.config.*`, `migrations/`, `schema.sql`
4. **Auth:** `auth.ts`, `middleware.ts`, auth-related packages in dependencies
5. **CI/CD:** `.github/workflows/`, `vercel.json`, `vercel.ts`, `Dockerfile`
6. **Design system:** `components/ui/`, shadcn config, component library packages

Build a stack profile:
```
Framework: Next.js 15 (App Router)
Language: TypeScript
Styling: Tailwind CSS + shadcn/ui
Database: Supabase (PostgreSQL + RLS)
Auth: Supabase Auth
Deployment: Vercel
Package manager: pnpm
```

---

## Step 3 — Directory structure scan

Map the top-level directory tree (2 levels deep). Identify:
- Source directories (`src/`, `app/`, `lib/`, `components/`)
- API route directories (`app/api/`, `pages/api/`, `routes/`)
- Component directories (`components/`, `components/ui/`, `components/features/`)
- Database directories (`supabase/`, `prisma/`, `migrations/`)
- Config files at root
- Test directories (`__tests__/`, `tests/`, `*.test.*`)

---

## Step 4 — Produce architecture.md

Write `DDD/projects/<slug>/dev/architecture.md`:

```markdown
# Architecture: <Project Name>

> Generated: <date>
> Codebase root: <path>
> Last mapped: <date>

## Stack
| Layer | Technology | Config |
|-------|-----------|--------|
| Framework | Next.js 15 (App Router) | next.config.ts |
| Language | TypeScript (strict) | tsconfig.json |
| Styling | Tailwind CSS + shadcn/ui | tailwind.config.ts |
| Database | Supabase (PostgreSQL) | supabase/ |
| Auth | Supabase Auth | lib/auth.ts |
| Deployment | Vercel | vercel.json |

## Directory Structure
<tree output, 2 levels deep, annotated>

## Patterns & Conventions
### File naming
- <observed pattern: kebab-case, PascalCase components, etc.>

### Import aliases
- <e.g., @/ → src/, @/components → components/>

### State management
- <observed: React Query, useState, Context, etc.>

### Error handling
- <observed patterns>

### Type organization
- <where types live: lib/types.ts, co-located, etc.>

## Key Files
| File | Purpose |
|------|---------|
| <path> | <purpose> |
```

---

## Step 5 — Produce api-map.md

Scan all API route files. For each route:

Write `DDD/projects/<slug>/dev/api-map.md`:

```markdown
# API Map: <Project Name>

> Generated: <date>
> Last updated: <date>

## Auth Pattern
<How auth is handled: middleware, per-route, Supabase RLS, etc.>

## Routes

### <METHOD> <path>
- **File:** <file path>
- **Auth:** required | public
- **Request:** <body shape or params>
- **Response:** <response shape>
- **Validation:** <how input is validated>
- **Notes:** <any special behavior>

<Repeat for each route>

## Summary Table

| Method | Path | Auth | File |
|--------|------|------|------|
| GET | /api/setups | required | app/api/setups/route.ts |
| POST | /api/setups | required | app/api/setups/route.ts |
```

---

## Step 6 — Produce component-map.md

Scan component directories. For each component:

Write `DDD/projects/<slug>/dev/component-map.md`:

```markdown
# Component Map: <Project Name>

> Generated: <date>
> Last updated: <date>

## UI Primitives (shadcn/ui or equivalent)
| Component | File | Variants |
|-----------|------|----------|
| Button | components/ui/button.tsx | default, secondary, destructive, outline, ghost, link |
| Card | components/ui/card.tsx | — |

## Feature Components
| Component | File | Props | Used In |
|-----------|------|-------|---------|
| SetupCard | components/features/setups/setup-card.tsx | setup: Setup, onEdit, onDelete | /setups page |

## Shared Components
| Component | File | Props |
|-----------|------|-------|
| EmptyState | components/shared/empty-state.tsx | title, description, action |

## Layouts
| Layout | File | Purpose |
|--------|------|---------|
| RootLayout | app/layout.tsx | Main app layout with nav |
```

---

## Step 7 — Produce db-schema.md

Scan database schema files (migrations, Prisma schema, Supabase types, etc.):

Write `DDD/projects/<slug>/dev/db-schema.md`:

```markdown
# Database Schema: <Project Name>

> Generated: <date>
> Last updated: <date>

## Tables

### <table_name>
- **Purpose:** <what this table stores>
- **RLS:** enabled | disabled
- **Indexes:** <list>

| Column | Type | Nullable | Default | FK |
|--------|------|----------|---------|-----|
| id | uuid | no | gen_random_uuid() | — |
| user_id | uuid | no | — | auth.users(id) |

### RLS Policies
| Policy | Operation | Rule |
|--------|-----------|------|
| Users read own | SELECT | user_id = auth.uid() |

<Repeat for each table>

## Relationships
<ASCII or table showing FK relationships>

## Enums / Custom Types
| Name | Values |
|------|--------|
```

---

## Step 8 — Summary and report

Invoke exec-write-memory to update `active_session.md`.

Present:
```
--------------------------------------------
  Codebase mapped: <Project Name>

  Stack: <framework> + <db> + <auth>
  API routes: <n> endpoints across <n> files
  Components: <n> UI primitives, <n> feature, <n> shared
  DB tables: <n> with <n> RLS policies
  
  Reference docs:
    dev/architecture.md
    dev/api-map.md
    dev/component-map.md
    dev/db-schema.md
--------------------------------------------
```

---

## Rules

- **Scan, don't assume** — read actual files, don't guess from framework name
- **Tables over prose** — every reference doc should be scannable, not readable
- **Include file paths** — every component, route, and table must link back to its source file
- **Re-runnable** — running code-mapper again overwrites existing docs (acts as a refresh)
- **Don't modify source code** — this is a read-only scan
- **Handle missing layers gracefully** — if no API routes exist, write api-map.md with "No API routes found"
- **Respect .gitignore** — don't scan node_modules, .next, dist, etc.
- **Cap depth** — scan components 3 levels deep max, routes 2 levels, don't recurse infinitely
