# ccconfig

Reusable skills and runtime adapters for two related but different environments:

- **Claude Code** uses skills and agents.
- **Codex** uses skills and plugins.

This repository treats **skills** as the canonical reusable content. Claude-specific agents live in [`agents/`](./agents), while Codex support is documented as skill installation plus future plugin packaging rather than a direct agent-to-agent mapping.

## What This Repo Is

This is a catalog of:

- reusable workflow skills under [`skills/`](./skills)
- Claude-specific runtime adapters under [`agents/`](./agents)
- packaging and compatibility references under [`configs/`](./configs)
- curated design history under [`docs/`](./docs)
- preserved raw research under [`investigations/`](./investigations) and selected [`tasks/`](./tasks)

This repo is **not** currently an active backup/deploy/testing platform for Claude or Codex configs. Some older documents describe that direction; they are retained as historical source material, not current product behavior.

## Runtime Model

### Claude Code

- **Canonical content**: skills in `skills/<name>/SKILL.md`
- **Runtime adapters**: agent definitions in `agents/*.md`
- **Install flow**: described in [`AGENTS.md`](./AGENTS.md)

### Codex

- **Canonical content**: skills in `skills/<name>/SKILL.md`
- **Optional metadata**: `skills/<name>/agents/openai.yaml`
- **Installable distribution unit**: plugins
- **Local development path**: direct skill installation or symlink-based authoring

Important distinction:

- `SKILL.md` is the canonical skill artifact.
- `agents/openai.yaml` is optional Codex/OpenAI metadata for UX and dependency declaration.
- Plugins package one or more skills plus optional assets, MCP/app integrations, and UI metadata.

## Portability

This repo contains a mix of portable and runtime-specific artifacts.

### Portable-first

These are the best current candidates for dual use in Claude Code and Codex with minimal adaptation:

- `cli-jesus`
- `conventional-commits`
- `git-context-recovery`
- `python-class-design`
- `reduce-hallucinations`
- `round`
- `terminal-tool-bootstrap`

### Likely Codex wrapper needed

These have useful content but should be documented or packaged more carefully before presenting them as Codex-ready:

- `persona-forge`
- `persona-forge-online`
- `find-skills`
- `context-window-inspector`
- `self-audit`
- `skill-police`

### Claude-only for now

These are currently Claude runtime adapters or are strongly tied to Claude agent semantics:

- `kim`
- `scout`
- `config-cleaner`
- `chris`
- `major-lazer`

## Installation Overview

### Claude Code

Use the installation flow in [`AGENTS.md`](./AGENTS.md).

In short:

- copy a whole skill directory into `~/.claude/skills/<name>/`
- copy an agent markdown file into `~/.claude/agents/<name>.md`

### Codex Local Skill Installation

Codex can use skill directories directly for local authoring and experimentation.

Current local convention on this machine:

- `~/.codex/skills/<name>/SKILL.md`

Direct installation options:

- copy the whole skill directory
- symlink the skill directory for local development

Guidance:

- symlink the **entire** skill directory, not just `SKILL.md`
- expect to restart Codex if a newly added skill is not picked up immediately
- do not assume a parallel `~/.codex/agents` install path
- use `scripts/link-agent-assets.sh --codex-only --apply` if you want the curated Codex-ready skill subset symlinked into `~/.codex/skills/`

### Codex Plugin Direction

For reusable distribution, Codex should be treated as:

- **skill** = authoring unit
- **plugin** = installable distribution unit

This repo does not yet implement the planned Codex plugins. The strategy and rationale are documented in:

- [`docs/codex-packaging.md`](./docs/codex-packaging.md)
- [`docs/personality-strategy.md`](./docs/personality-strategy.md)

## Canonical Docs

The current repo model is defined by four docs:

- [`docs/repo-model.md`](./docs/repo-model.md)
- [`docs/history-and-lineage.md`](./docs/history-and-lineage.md)
- [`docs/codex-packaging.md`](./docs/codex-packaging.md)
- [`docs/personality-strategy.md`](./docs/personality-strategy.md)

Everything else under `docs/`, `tasks/`, and `up_claude/` should be treated as source material, retained only because it still contains useful rationale, raw research, or detailed specs.

## Repository Structure

```text
ccconfig/
├── skills/           # Canonical reusable workflow content
├── agents/           # Claude-specific runtime adapters
├── configs/          # Reference manifests and packaging helpers
├── docs/             # Canonical docs plus retained source material
├── investigations/   # Raw incident and research evidence
├── tasks/            # Selected detailed design packets
└── up_claude/        # Archived source material from earlier design work
```

## Historical Context

The repo grew out of the 2025-12-18 claude-mem overhead investigation and the follow-on push to:

- audit what actually consumes tokens
- search for existing tools before building
- keep observability pull-based rather than always-on
- separate reusable skills from runtime-specific adapters

That lineage is summarized in [`docs/history-and-lineage.md`](./docs/history-and-lineage.md).

## License

MIT
