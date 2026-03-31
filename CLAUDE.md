# CLAUDE.md

This file provides contributor guidance for working in this repository.

## Current Repo Purpose

`ccconfig` is a catalog of reusable skills plus runtime-specific adapters and packaging references for:

- **Claude Code**
- **Codex**

The repo is organized around one core rule:

- **skills are the canonical reusable content**

Everything else is packaging, runtime adaptation, or preserved design history.

## Current Model

### Canonical content

- `skills/` contains reusable workflow content
- each skill is a directory with required `SKILL.md` and optional supporting files

### Runtime-specific content

- `agents/` contains Claude-specific runtime adapters
- Codex support is documented as skills plus plugins, not direct agent parity

### Supporting material

- `configs/` contains reference manifests and packaging helpers
- `docs/` contains canonical docs plus retained source material
- `investigations/` contains raw incident evidence
- `tasks/` contains selected design packets that still have implementation value
- `up_claude/` is archived source material from earlier design work

## Working Principles

### 1. Preserve before collapsing

When cleaning up historical material:

- keep raw evidence when it is uniquely useful
- summarize overlapping narrative into canonical docs
- avoid losing design rationale while reducing surface area

### 2. Do not pretend the runtimes are identical

Claude Code and Codex overlap, but they are not structurally identical.

- Claude Code: skills + agents
- Codex: skills + plugins

Do not force a fake one-to-one mapping just to make the repo look uniform.

### 3. Keep repo claims accurate

Some historical documents describe larger plans for config deployment, test harnesses, observability systems, and profile management. Those ideas may still be useful as source material, but they are not current product behavior unless the repo actually implements them.

Do not reintroduce stale claims about:

- backup/deploy scripts being active repo features
- a populated testing platform that does not exist
- experimental/production config promotion workflows as current behavior

If such ideas matter, describe them as historical designs or future work.

### 4. Prefer compact canonical docs

The canonical conceptual docs are:

- `docs/repo-model.md`
- `docs/history-and-lineage.md`
- `docs/codex-packaging.md`
- `docs/personality-strategy.md`

Other docs are retained as source material unless explicitly promoted into the canonical set.

## Editing Guidance

When updating this repo:

- prefer improving canonical docs over adding new narrative files
- for small historical notes, fold them into the canonical docs rather than creating new task folders
- avoid aggressive reorganization of `skills/` and `agents/` during cleanup-only work
- treat `agents/openai.yaml` as optional Codex/OpenAI metadata, not as the canonical skill definition

## Installation Guidance

For Claude installation behavior, use `AGENTS.md`.

For Codex packaging and local install guidance, use:

- `docs/codex-packaging.md`
- `docs/personality-strategy.md`

## Repo Cleanup Goal

The cleanup target is a repo where:

- `README.md` gives a new reader the correct mental model quickly
- `AGENTS.md` remains narrowly Claude-specific
- `CLAUDE.md` helps contributors avoid reviving stale architecture claims
- historical intent remains recoverable without competing with the active entrypoints
