# agentify

Coding agents, skills, plugins, and configuration guidelines for Claude Code and Codex.

## Install

### Skills

```bash
ln -s /path/to/agentify/skills/<name> ~/.claude/skills/<name>
```

### Agents

```bash
ln -s /path/to/agentify/agents/<name>.md ~/.claude/agents/<name>.md
```

Symlinks mean edits in the repo take effect immediately — no re-install step.

## What's Available

### General Purpose Skills

| Skill | What It Does |
|-------|-------------|
| `cli-jesus` | Expert command-line advice grounded in art-of-command-line reference |
| `conventional-commits` | Enforces Conventional Commits spec for git commit messages |
| `context-window-inspector` | Estimates context window overhead and audits Claude Code config for token bloat |
| `find-skills` | Locates relevant skills and agents for a given task |
| `git-context-recovery` | Recovers prior-session work context from git history |
| `python-class-design` | Reviews Python class design, catches antipatterns |
| `reduce-hallucinations` | Prompt grounding techniques for factual accuracy |
| `round` | Session transition notes for multi-day work continuity |
| `self-audit` | Periodic audit of Claude Code config quality |
| `skill-police` | Audits skills for spec compliance and frontmatter correctness |
| `skillshare-operator` | Manage and sync skills/agents across Claude Code, Codex, Gemini, and other runtimes via skillshare |
| `terminal-tool-bootstrap` | Installs/configures terminal tools (yazi, zellij, fzf, bat, etc.) |

### Domain-Specific Skills

| Skill | Domain | What It Does |
|-------|--------|-------------|
| `beads` | Task tracking | Reference for `bd` CLI task tracker (requires `bd` installed) |
| `ep133-device` | Music hardware | EP-133 KO-II device slot/bank/pad layout |
| `ep133-protocol` | Music hardware | EP-133 KO-II SysEx protocol for upload/download |
| `ghostty-config` | Terminal | Ghostty terminal emulator configuration |
| `midi-rekordbox` | DJ software | Rekordbox MIDI Learn CSV mapping format |
| `pcq-reviewer` | Burning Man | Placement questionnaire review for camp applications |
| `session-notes-writer` | Workflow | Proactive session note writing (experimental) |

### Agents

| Agent | What It Does |
|-------|-------------|
| `chris` | Adversarial research — tries to prove claims wrong, finds edge cases |
| `config-cleaner` | Scans Claude Code config for stale refs, dead permissions, orphans. Report-only. |
| `major-lazer` | DJ workflow, MIDI mapping, controller ergonomics, mix strategy |
| `scout` | Searches for existing MCP servers/plugins/agents before you build from scratch |

### Guidelines

Configuration guides for handy Claude Code and Codex features live in `guidelines/`.

## Repo Layout

```text
skills/       Reusable standalone skills
agents/       Claude-specific agents
guidelines/   Feature configuration guides
docs/         Design notes and canonical docs
scripts/      Local tooling (symlink helpers, dev layout)
```

## License

MIT
