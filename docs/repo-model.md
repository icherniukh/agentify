# Repo Model

This document defines the current source-of-truth model for `ccconfig`.

## Core Rule

**Skills are the canonical reusable content.**

Everything else in the repo should be interpreted relative to that rule.

## Artifact Taxonomy

### `skills/`

Use `skills/` for reusable workflow content.

Expected shape:

- `skills/<name>/SKILL.md` is required
- `references/`, `scripts/`, `templates/`, and `assets/` are optional
- `agents/openai.yaml` is optional Codex/OpenAI metadata when useful

These are the best candidates for cross-runtime reuse.

### `agents/`

Use `agents/` for Claude-specific runtime adapters.

These files are not the canonical source of reusable knowledge; they are Claude packaging for behavior that may or may not later be recast as Codex skills or plugins.

### `configs/`

Use `configs/` for:

- reference manifests
- example settings or compatibility material
- packaging helpers

Do not describe `configs/` as an active config deployment platform unless the repo actually implements that system.

### `docs/`

Use `docs/` for:

- canonical conceptual guidance
- compact preserved design lineage
- packaging strategy

Non-canonical docs in this folder are retained as source material, not as first-line entrypoints.

### `investigations/`

Use `investigations/` for raw evidence with enduring value, especially incident reports and research findings that should remain intact.

### `tasks/`

Use `tasks/` for detailed design packets worth retaining because they still contain implementation-grade detail. Do not expand task sprawl during cleanup work.

### `up_claude/`

Treat `up_claude/` as archived source material from an earlier design phase. It is not a primary product surface.

## Runtime Model

### Claude Code

- canonical content: skills
- runtime adapters: agents
- install flow: `AGENTS.md`

### Codex

- canonical content: skills
- optional metadata: `agents/openai.yaml`
- installable unit: plugins
- local authoring path: direct skill installation or symlinked skill directories

## Portability Classes

Use these categories when documenting or packaging artifacts:

### Portable skill

Content is useful in both Claude Code and Codex with minimal adaptation.

Current baseline:

- `cli-jesus`
- `conventional-commits`
- `git-context-recovery`
- `python-class-design`
- `reduce-hallucinations`
- `round`
- `terminal-tool-bootstrap`

### Codex wrapper needed

The underlying content is useful, but Codex-facing packaging or adaptation is still needed.

Current baseline:

- `persona-forge`
- `persona-forge-online`
- `find-skills`
- `context-window-inspector`
- `self-audit`
- `skill-police`

### Claude-only for now

The artifact is strongly tied to Claude agent semantics, Claude-specific tools, or Claude-oriented packaging.

Current baseline:

- `kim`
- `scout`
- `config-cleaner`
- `chris`
- `major-lazer`

## Non-Goals

This repo model deliberately does not:

- force Claude and Codex into a fake one-to-one structure
- treat all narrative/design files as current product docs
- describe historical configuration-platform ideas as live functionality

## Provenance

This document condenses and normalizes intent drawn from:

- `README.md` history
- `CLAUDE.md` history
- `docs/roadmap.md`
- `docs/philosophy.md`
- `docs/agent-design-specs.md`
- `docs/inconsistencies-report.md`
