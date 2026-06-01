# CLAUDE.md

This file provides contributor guidance for working in this repository.

## Current Repo Purpose

This repo is a catalog of coding-focused agents, skills, and plugins for Claude Code and Codex.

The core rule: **skills are the canonical reusable content.** Everything else is packaging, runtime adaptation, or preserved design history.

## Structure

- `skills/` — reusable workflow skills, each with a required `SKILL.md`
- `agents/` — Claude-specific runtime agents
- `configs/agents/` — staging area for agent drafts and alternates not yet promoted to `agents/`
- `docs/` — canonical docs plus retained source material
- `investigations/` — raw incident evidence worth preserving
- `scripts/` — local tooling (symlink helpers, dev layout scripts)

## Plugin Bundle Taxonomy

The skills and agents fall into natural groups that are candidates for future installable plugins. Revisit this taxonomy as new content lands:

| Bundle | Contents |
|--------|----------|
| **git-workflow** | `conventional-commits`, `git-context-recovery` |
| **code-meta** | `self-audit`, `skill-police`, `context-window-inspector`, `find-skills`, `config-cleaner` agent |
| **terminal-setup** | `cli-jesus`, `terminal-tool-bootstrap`, `ghostty-config` |
| **code-review** | `python-class-design`, `reduce-hallucinations`, `chris` agent |
| **personal-domain** | `ep133-device`, `ep133-protocol`, `midi-rekordbox`, `pcq-reviewer` |

Skills not yet assigned to a bundle: `round`, `session-notes-writer`, `beads`.

## Working Principles

### Keep repo claims accurate

Do not reintroduce stale claims about:
- backup/deploy scripts being active repo features
- a populated testing platform that does not exist
- experimental/production config promotion workflows as current behavior

### Prefer compact canonical docs

The canonical docs are:
- `docs/repo-model.md`
- `docs/history-and-lineage.md`
- `docs/codex-packaging.md`

Other docs are retained as source material unless explicitly promoted into the canonical set.

### Preserve before collapsing

When cleaning up historical material: keep raw evidence when it is uniquely useful, summarize overlapping narrative into canonical docs.

## Editing Guidance

- Prefer improving canonical docs over adding new narrative files
- Avoid aggressive reorganization of `skills/` and `agents/` during cleanup-only work
- `agents/openai.yaml` inside a skill dir is optional Codex metadata, not the canonical definition

## Installation Guidance

For Claude installation behavior, see `AGENTS.md`.
For Codex packaging, see `docs/codex-packaging.md`.
