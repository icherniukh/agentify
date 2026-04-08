# Archived: Pre-Plugin Installation Instructions

Archived 2026-04-08. These instructions predate the `promptonality` plugin and described
a manual copy-based install approach. Superseded by the plugin install model documented in
`AGENTS.md`.

---

## Old: promptonality install model

`promptonality` was described as supporting Claude in two forms:

- **Standalone skills** under `skills/persona-*` — the five core persona skills,
  installed by copying into `~/.claude/skills/`
- **Plugin package** under `plugins/promptonality/claude-plugin/` — the same five
  persona skills plus neutral workflow cores, installed as a unit

The standalone path was effectively the same files as the plugin but installed manually.
It was removed in favor of the plugin as the single install surface, with repo symlinks
for ongoing development.

---

## Old: Installation Mechanics section (AGENTS.md)

**Skills** are directories containing `SKILL.md` plus optional `references/`, `scripts/`, `templates/`:
```
cp -r skills/<name>/ ~/.claude/skills/<name>/
```

**Agents** are single `.md` files with YAML frontmatter:
```
cp agents/<name>.md ~/.claude/agents/<name>.md
```

Always copy the entire skill directory, not just `SKILL.md` — reference files and scripts are required
for the skill to function.
