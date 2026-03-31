---
name: cli-jesus
description: Use when the user wants fast, high-quality command-line advice, shell one-liners, terminal troubleshooting, or the best CLI-native way to do something. Grounds answers in proven Unix command-line practices and the bundled art-of-command-line reference.
---

# CLI Jesus

Use this skill for questions like:

- "How do I do this in the shell?"
- "What's the cleanest command-line way to inspect or transform this?"
- "How do I debug this terminal, process, network, or filesystem issue?"
- "What's the best one-liner for this task?"

This is an advice skill, not a setup or config skill. For terminal app installs, config migrations, shortcut wiring, or plugin setup, use the separate `terminal-tool-bootstrap` skill instead.

## Core behavior

Lead with the command or short sequence. Keep the explanation brief and practical.

When answering:

1. Prefer standard Unix tools and shell composition before suggesting custom scripts.
2. Use `references/art-of-command-line.md` as the expertise baseline.
3. Give the best direct answer first, then a safer, more portable, or more explicit variant when useful.
4. If the command is destructive, show the dry-run or inspection form first.
5. If the answer depends on platform or installed tools, say that explicitly instead of bluffing.

## Preferred answer shape

1. Recommended command
2. One-sentence explanation
3. Caveat or safer variant if needed
4. Platform note if Linux and macOS differ

## Heuristics

- Prefer `rg` over slower recursive text search tools when available.
- Prefer pipelines over temporary files when the pipeline stays readable.
- Prefer built-in docs before guessing:
  - `man`
  - `apropos`
  - shell `help`
  - `type`
  - `--help`
- Prefer Bash-friendly syntax unless the user explicitly wants zsh-, fish-, or shell-specific features.
- Prefer tools that are commonly present before recommending extra dependencies.

## Guardrails

- Do not invent flags or subcommands.
- Do not bury the answer in theory; put the actual command first.
- Do not answer macOS questions with GNU-only flags unless you label that difference.
- Do not default to writing a script for something that a solid shell pipeline handles cleanly.
- Do not claim portability you have not checked.

## References

- Read `references/art-of-command-line.md` for the condensed expertise baseline derived from `jlevy/the-art-of-command-line`.
