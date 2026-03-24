# DDD — Design System Agent

A domain-agnostic design agent that scans your Figma UI kit and assists with building, documenting, and managing design system components.

## Requirements

- [Claude Code](https://claude.com/claude-code) CLI
- [Figma Console MCP](https://github.com/anthropics/figma-console-mcp) server connected
- A Figma file with an existing UI kit (shadcn, Radix, Material, etc.)

## Install

```bash
./install.sh /path/to/your/project
```

This will:
1. Create `design-system/` in your project with knowledge-base and memory directories
2. Symlink all `ds-*` skills into your project's `.claude/skills/`
3. Append a design system section to your project's `CLAUDE.md`

On first conversation, Claude will detect the empty knowledge-base and auto-run `/ds-init` to scan your Figma file.

## Uninstall

```bash
./uninstall.sh /path/to/your/project
```

## Commands

| Command | Purpose |
|---------|---------|
| `/ds-init` | Scan Figma file, populate knowledge-base |
| `/ds-plan` | Plan a new component (interview → spec) |
| `/ds-build` | Build a component in Figma |
| `/ds-add-variant` | Add variant/state to existing component |
| `/ds-doc` | Generate component documentation |
| `/ds-spec` | Generate engineering implementation spec |
| `/ds-handoff` | Create tickets in your tracker |
| `/ds-token` | Find the right token for a design intent |
| `/ds-update` | Re-scan Figma, show what changed |
| `/ds-audit` | Check all components against conventions |
| `/ds-verify` | Screenshot-verify a component |
| `/ds-feedback` | Capture workflow preferences |
| `/ds-memory` | Manage persistent memory |
| `/ds-help` | Show system status |

## Version

See `VERSION` file. Each installed project records its version in `design-system/config.md`.
