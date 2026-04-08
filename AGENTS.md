# AGENTS.md

This repo is a catalog of Claude Code skills and agents. Users will ask you to install one, several, or all of them.

This file is intentionally **Claude-specific**. Codex support is documented separately in the repository docs because Codex uses skills plus plugins rather than this `agents/` installation flow.

`promptonality` is installed as a Claude Code plugin. It provides the five persona skills plus
neutral workflow cores for dynamic composition.

```bash
claude plugin install promptonality@local
```

The plugin includes neutral workflow cores composable with any personality pack via `persona-start` or `persona-apply`:

| Workflow Core | What It Does |
|---------------|-------------|
| `orchestrator-core` | Neutral orchestration workflow: decomposes tasks, selects specialists, compresses state |
| `architecture-review-core` | Neutral architecture review: evaluates structure, boundaries, abstractions, dependencies, and maintainability risks |

To apply a persona to a workflow core, use `persona-start` — no dedicated variant skill required. For example: "use `orchestrator-core` with the Sam Harris persona for this session."

To regenerate the plugin package after editing personas or skills:

```bash
python3 plugins/promptonality/scripts/export_claude_plugin.py
```

## Installation Mechanics

**Skills** (non-promptonality) are installed as symlinks from the repo:
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
| `persona-apply` | Applies a bundled persona to the current task or thread without making it session-default |
| `persona-extract` | Distills a public figure or character into a normalized persona pack |
| `persona-extract-online` | Research-backed version of persona-extract |
| `persona-list` | Lists bundled persona packs available in the Claude-facing promptonality package |
| `persona-start` | Makes a workflow or persona-composed mode the default for the rest of the session |
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
| `scout` | Searches for existing MCP servers/plugins/agents before you build from scratch |

## Dependencies

Most skills are self-contained. Exceptions:

- **beads**: Requires `bd` CLI installed (`pip install beads-cli` or equivalent)
- **cli-jesus**: Bundles `references/art-of-command-line.md` (included in skill dir)
- **ghostty-config**: Bundles 4 reference files (included in skill dir)
- **persona-list**: Bundles persona YAMLs plus `scripts/persona_list.py`
- **persona-start** / **persona-apply**: Bundle persona YAML references
- **persona-extract** / **persona-extract-online**: Bundle the persona-pack contract reference
- **terminal-tool-bootstrap**: Bundles reference + probe script (included in skill dir)
- **chris** (agent): References `mcp__web_reader__webReader` tool — works without it but loses web reading capability. `WebSearch` + `WebFetch` are built-in alternatives.

## Post-Install

After installing, restart Claude Code or start a new session. Skills and agents are discovered automatically from `~/.claude/skills/` and `~/.claude/agents/`.

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->
