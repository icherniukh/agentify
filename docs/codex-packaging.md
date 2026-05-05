# Codex Packaging

This document defines the Codex-side strategy for `ccconfig`.

## Bottom Line

For Codex:

- **skill** = authoring unit
- **plugin** = installable distribution unit

This repo should not attempt to mirror the Claude `agents/` model directly into Codex.

## Skill Structure

The canonical skill artifact is:

```text
skills/<skill-name>/SKILL.md
```

Optional skill-local content may include:

- `references/`
- `scripts/`
- `templates/`
- `assets/`
- `agents/openai.yaml`

Important:

- `SKILL.md` is required
- `agents/openai.yaml` is optional
- a skill is still valid without `openai.yaml`

## What `agents/openai.yaml` Is

Use `agents/openai.yaml` as optional Codex/OpenAI metadata.

It is appropriate for:

- user-facing name and description
- icons and branding
- default prompt or invocation guidance
- dependency declarations

It is **not**:

- the canonical skill definition
- a requirement for the open Agent Skills authoring contract
- evidence that a skill is universally Codex-ready

Repository policy:

- include it when Codex UX or dependency declaration benefits from it
- omit it for simple portable skills where `SKILL.md` is enough

Current examples in this repo:

- `skills/cli-jesus/agents/openai.yaml`
- `skills/terminal-tool-bootstrap/agents/openai.yaml`

## Local Codex Installation

For local development and experimentation, direct skill installation is acceptable.

Current working convention:

- `~/.codex/skills/<skill-name>/SKILL.md`

Supported local workflows:

- copy the full skill directory into `~/.codex/skills/`
- symlink the full skill directory into `~/.codex/skills/`

Repo helper:

- `scripts/link-agent-assets.sh --codex-only --apply` links the curated Codex-ready subset, not every skill in the repo

Recommended practice:

- symlink the entire skill folder, not just `SKILL.md`
- restart Codex if a newly installed skill does not appear immediately

Do not document or imply a fake `~/.codex/agents` installation path.

## Codex Plugins

Use plugins when distribution needs exceed a single loose skill folder.

Good plugin candidates:

- bundles of related skills
- skills that need MCP or app dependencies
- skills that benefit from better Codex discovery and UI polish
- cross-cutting systems such as personality handling

Expected Codex plugin artifact:

- `.codex-plugin/plugin.json`

Current implemented example in this repo:

- `plugins/promptonality/.codex-plugin/plugin.json`

Current guidance:

- treat `plugins/promptonality/` as the repo-local plugin source of truth
- keep plugin-specific installation and export notes in `plugins/promptonality/README.md`
- do not document or imply a stable user-home plugin install path unless Codex runtime docs explicitly support it

## Relationship to Existing Repo Files

### `agents/`

Claude-specific agents remain where they are. They are not treated as Codex-installable artifacts.

### `configs/reference/plugin.json`

`configs/reference/plugin.json` remains useful as historical/reference packaging material for the Claude-oriented side of the repo. It should not be presented as the primary Codex packaging format.

For Codex planning, the relevant direction is `.codex-plugin/plugin.json`.

## Portability Baseline

### Best first candidates for direct Codex skill use

- `cli-jesus`
- `conventional-commits`
- `git-context-recovery`
- `python-class-design`
- `reduce-hallucinations`
- `round`
- `terminal-tool-bootstrap`

### Candidates that should be wrapped or adapted first

- `persona-forge`
- `persona-forge-online`
- `find-skills`
- `context-window-inspector`
- `self-audit`
- `skill-police`

### Not direct Codex targets yet

- `kim`
- `scout`
- `config-cleaner`
- `chris`
- `major-lazer`

## Provenance

This document condenses and stabilizes guidance drawn from:

- local Codex installation behavior observed under `~/.codex/`
- `skills/*/agents/openai.yaml`
- `configs/reference/plugin.json`
- `README.md` history
- task/design material related to repo positioning
