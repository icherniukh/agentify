# AGENTS.md

This repo is a catalog of Claude Code skills and agents. Users will ask you to install one, several, or all of them.

This file is intentionally **Claude-specific**. Codex support is documented separately in the repository docs because Codex uses skills plus plugins rather than this `agents/` installation flow.

## Installation Mechanics

**Skills** are installed as symlinks from the repo:
```bash
ln -s /path/to/ccconfig/skills/<name> ~/.claude/skills/<name>
```

**Agents** are installed as symlinks too:
```bash
ln -s /path/to/ccconfig/agents/<name>.md ~/.claude/agents/<name>.md
```

Symlinks mean edits in the repo take effect immediately — no re-install step.

> Previous instructions described a `cp -r` copy-based approach. That is archived in
> `docs/_archive/install-pre-plugin.md`.

## Handling "Install All"

When asked to install everything, install only the **General Purpose** items by default. List the **Domain-Specific** items and ask which (if any) the user also wants. Domain-specific skills are useful only if the user works with that particular tool/format.

## What's Available

### General Purpose Skills

| Skill | What It Does |
|-------|-------------|
| `cli-jesus` | Expert command-line advice grounded in art-of-command-line reference |
| `conventional-commits` | Enforces Conventional Commits spec for git commit messages |
| `git-context-recovery` | Recovers prior-session work context from git history |
| `python-class-design` | Reviews Python class design, catches antipatterns |
| `reduce-hallucinations` | Prompt grounding techniques for factual accuracy |
| `round` | Session transition notes for multi-day work continuity |
| `self-audit` | Periodic audit of Claude Code config quality |
| `skill-police` | Audits skills for spec compliance and frontmatter correctness |
| `terminal-tool-bootstrap` | Installs/configures terminal tools (yazi, zellij, fzf, bat, etc.) |
| `context-window-inspector` | Estimates context window overhead and audits Claude Code configuration for token bloat |

### Domain-Specific Skills

| Skill | Domain | What It Does |
|-------|--------|-------------|
| `beads` | Task tracking | Reference for `bd` CLI task tracker (requires `bd` installed) |
| `ep133-device` | Music hardware | EP-133 KO-II device slot/bank/pad layout |
| `ep133-protocol` | Music hardware | EP-133 KO-II SysEx protocol for upload/download |
| `ghostty-config` | Terminal | Ghostty terminal emulator configuration |
| `midi-rekordbox` | DJ software | Rekordbox MIDI Learn CSV mapping format |
| `pcq-reviewer` | Burning Man | Placement questionnaire review for camp applications |
| `session-notes-writer` | Workflow | Proactive session note writing (archived, experimental) |

### Agents

| Agent | What It Does |
|-------|-------------|
| `config-cleaner` | Scans Claude Code config for stale refs, dead permissions, orphans. Report-only. |
| `major-lazer` | DJ workflow, MIDI mapping, controller ergonomics, mix strategy — in character as the Guardian of the Groove |
| `chris` | Adversarial research — tries to prove claims wrong, finds edge cases |
| `kim` | Claude Code configuration specialist with structured workflow |
| `scout` | Searches for existing MCP servers/plugins/agents before you build from scratch; refresh source map lives in `agents/scout-refs/ecosystem-sources.md` |

## Dependencies

Most skills are self-contained. Exceptions:

- **beads**: Requires `bd` CLI installed (`pip install beads-cli` or equivalent)
- **cli-jesus**: Bundles `references/art-of-command-line.md` (included in skill dir)
- **ghostty-config**: Bundles 4 reference files (included in skill dir)
- **terminal-tool-bootstrap**: Bundles reference + probe script (included in skill dir)
- **chris** (agent): References `mcp__web_reader__webReader` tool — works without it but loses web reading capability. `WebSearch` + `WebFetch` are built-in alternatives.

## Post-Install

After installing, restart Claude Code or start a new session. Skills and agents are discovered automatically from `~/.claude/skills/` and `~/.claude/agents/`.

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking.

- Run `bd prime` for the current workflow context.
- Core commands: `bd ready`, `bd show <id>`, `bd update <id> --claim`, `bd close <id>`.
- Use `bd` for persistent task tracking instead of markdown TODO lists.
- Use `bd remember` only for evergreen facts not already captured well in issue descriptions.
<!-- END BEADS INTEGRATION -->
