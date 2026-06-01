---
name: skillshare-operator
description: >
  Use when deciding how to manage, audit, sync, enable, disable, or troubleshoot
  skills and agents with the skillshare CLI across Claude Code, Codex, Gemini,
  OpenCode, Kiro, Goose, Pi, Antigravity, or project-local .skillshare setups.
  Especially use for questions about global vs project mode, disabled-by-default
  policies, .skillignore/.agentignore, target drift, broken symlinks, duplicate
  skills, sync dry-runs, or whether to use skillshare versus a runtime-native
  tool such as Codex skill-manager.
metadata:
  short-description: Operate skillshare safely
---

# Skillshare Operator

Use this skill to manage Skillshare as a source-of-truth and sync layer. Keep the work audit-first, dry-run-first, and explicit about which runtime owns final enablement.

## Operating Model

- Treat Skillshare as the canonical file sync layer for shared skills, agents, and extras.
- Treat `/Users/ivan/.skills` as the current global source unless `skillshare status` says otherwise.
- Treat project `.skillshare/` directories as repo-specific source and policy overlays.
- Treat `.skillignore` and `.agentignore` as Skillshare-level enable/disable policy.
- Treat Codex `.codex/config.toml` as the better tool for native per-project enablement when a skill should remain installed in `~/.codex/skills` but disabled by default.
- Do not assume Skillshare enablement equals runtime-native enablement. It controls what syncs; each runtime may still have its own discovery and trigger behavior.

## First Commands

Run these before recommending changes:

```bash
skillshare status
skillshare target list
skillshare list --all --verbose
skillshare doctor --json
skillshare sync --dry-run --all --json
```

If working inside a repo that may have project policy, also run:

```bash
find .. -name .skillshare -maxdepth 3 -type d
skillshare status -p
skillshare target list -p
skillshare sync -p --dry-run --all --json
```

## Decision Guide

Use Skillshare when the task is:

- syncing the same skill/agent content to multiple coding agents
- collecting existing runtime-local skills back into the shared source
- auditing broken symlinks, duplicate skills, sync drift, or stale targets
- managing shared source with git checkpoints
- creating project-local `.skillshare/` policy for a repo
- controlling coarse sync visibility with `.skillignore` or `.agentignore`

Use Codex `skill-manager` when the task is:

- keeping a user-level Codex skill installed but disabled by default
- enabling a specific skill for one Codex project via `.codex/config.toml`
- avoiding plugin-cache path overrides
- managing Codex-only scope without changing Claude/Gemini/OpenCode targets

Use runtime-specific tools when the task is:

- enabling/disabling Claude plugins rather than file-based skills
- managing MCP server auth, OAuth, or runtime settings
- changing tool permissions rather than skill files

## Safe Mutation Rules

1. Prefer `--dry-run` before any sync, install, uninstall, collect, or target change.
2. Back up before broad syncs:

```bash
skillshare backup
```

3. After mutating source or policy, run:

```bash
skillshare doctor --json
skillshare sync --dry-run --all --json
```

4. Only run a real sync when the dry-run target list and touched files are understood.
5. Never delete target files manually to fix Skillshare. Use `skillshare uninstall`, `skillshare trash restore`, `skillshare target remove`, or `skillshare sync --force` only after reviewing impact.
6. If `doctor` reports broken symlinks or duplicate skills, fix those before adopting a new sync policy.

## Disabled-By-Default Pattern

For Skillshare-level policy:

```bash
skillshare disable "*" -g --dry-run
skillshare enable beads -g --dry-run
skillshare sync --dry-run --all
```

Apply only after confirming the pattern works as intended. Use more specific globs where possible.

For project-specific policy:

```bash
skillshare init -p --targets "claude,codex" --no-copy
skillshare disable "*" -p --dry-run
skillshare enable beads -p --dry-run
skillshare sync -p --dry-run --all
```

If the goal is "available globally but only active in this Codex repo", prefer Codex `skill-manager` rather than Skillshare ignore rules.

## Report Shape

When reporting, include:

- source path and target list
- current mode: global or project
- sync mode: copy or symlink
- unsynced count and target drift
- broken symlinks and duplicate skills
- proposed policy: Skillshare ignore, project `.skillshare`, Codex config, or runtime-specific tool
- exact dry-run command to validate the next step

Keep recommendations scoped. Do not propose a full cross-agent resync when the user only asked about one project.
