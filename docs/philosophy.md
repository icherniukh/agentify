# Claude Code Optimization Plan

## Context
On 2025-12-18, discovered claude-mem was burning 2M tokens (~$30) creating 521 observations with 0% reuse. Root cause: enabled a plugin without understanding its behavior.

**Core problem:** No visibility into what tools are being used under the hood and what impact they have on workflow efficiency. Flying blind on runtime behavior.

**Lesson:** Search for existing solutions before building. Observe without creating overhead. Pull-based visibility, not push-based monitoring.

---

## 0. Search first (USE SCOUT)

Before building anything, search for existing solutions.

**Deployed:** `Scout` agent (`~/.claude/agents/scout.md`) - ecosystem discovery specialist.

**Usage:**
```
"Scout, I need observability into token usage. What exists?"
"Scout, what MCP servers handle database access?"
"Scout, are there tools for iterative CLAUDE.md improvement?"
```

Scout searches: anthropics/skills, ccplugins/marketplace, wshobson/agents, obra/superpowers, skillsmp.com, MCP directories.

**Principle:** Find before building. Many problems are already solved.

---

## 1. Understand the tool

Before optimizing anything, learn how Claude Code actually works.

**Actions:**
- Use `/cluddha` (or claude-code-guide agent) to research:
  - Settings hierarchy: global (`~/.claude/`) vs project (`.claude/`) vs CLI flags
  - What agents/tools are built-in vs plugins
  - How plugins attach hooks (this is how claude-mem created overhead)
  - What logging/metrics Claude Code already provides
  - Dynamic config switching options

**Output:** Notes in this repo documenting the architecture.

---

## 2. Inventory current state (ONE SESSION)

Simple audit of what's enabled.

**Plugins:**
```bash
cat ~/.claude/settings.json | jq '.plugins'
# For each: Have I used this? What hooks does it register?
```

**Commands:**
```bash
ls ~/.claude/commands/ .claude/commands/
# For each: Have I invoked this in the last week?
```

**MCP servers:**
```bash
cat ~/.claude/settings.json | jq '.mcpServers'
# For each: What capabilities? When did I last use them?
```

**Agents:**
```bash
ls ~/.claude/agents/ .claude/agents/
# For each: Is this actively used or aspirational?
```

**Output:** Table in this repo: `inventory.md` with columns: Item | Type | Last Used | Keep/Remove/Investigate

---

## 3. Cleanup (IMMEDIATE after inventory)

Based on inventory:
- Disable unused plugins (move to `plugins-disabled/` or remove from settings)
- Archive unused commands
- Disable MCP servers you don't use

**Rule:** If you haven't used it in 2 weeks and can't articulate why you need it, disable it.

---

## 4. Observe (MANUAL, OCCASIONAL)

Don't build monitoring systems. Use existing data manually.

**What exists:**
- `~/.claude/history.jsonl` - your session history
- Claude Code's own logs (research location in step 1)

**On-demand analysis agent:**
Create an agent that, when invoked manually:
- Parses recent history.jsonl
- Summarizes: which tools you used, session patterns
- Suggests: built-in tools you might be underusing

This is a PULL action, not automatic. Run it weekly if curious.

---

## 5. Evolve CLAUDE.md (ONGOING HABIT, not system)

No "A/B testing framework." Just:

- When Claude ignores an instruction → investigate why, fix the wording
- When you discover a useful pattern → add it
- When you waste tokens → note the cause
- When a project has specific needs → add project CLAUDE.md

Version control tracks the evolution naturally.

---

## 6. Config management

**Project-level plugins:**
Enable plugins per-project via `.claude/settings.json`:
```json
{"enabledPlugins": {"compound-engineering@every-marketplace": true}}
```

**Surgical extraction:**
Don't enable bloated plugins globally. Extract just what you need:
```bash
cp -r ~/.claude/plugins/.../skills/useful-skill ~/.claude/skills/
cp ~/.claude/plugins/.../commands/useful-cmd.md ~/.claude/commands/
```

**Config profiles (optional):**
```
~/.claude/profiles/
  minimal.settings.json
  research.settings.json
```
Switch: `cp ~/.claude/profiles/minimal.settings.json ~/.claude/settings.json`

---

## Execution order

1. **Use Scout** to search for existing solutions to visibility/observability needs
2. **Understand** Claude Code config architecture (use /cluddha)
3. **Inventory and cleanup** - one focused session
4. **Observe and evolve** - ongoing habits, not systems
5. **Config profiles** - as use cases emerge

---

## Anti-patterns to avoid

- **Building systems before understanding** - claude-mem's mistake
- **Automatic/continuous monitoring** - creates the overhead you're trying to measure
- **Arbitrary metrics** - "20% reduction" is meaningless without baseline
- **Over-engineering personal workflow** - you're one person, not an enterprise

---

## Success looks like

- You have visibility into what tools run and their token impact
- You know exactly what's enabled and why
- You search for existing solutions before building (Scout)
- You have a simple way to check usage patterns when curious
- Your CLAUDE.md improves over time based on real experience
- Zero monitoring overhead eating tokens
