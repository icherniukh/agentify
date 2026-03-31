# Rue — Head of Staff Orchestrator

**Date:** 2026-03-27
**Status:** Implemented
**Location:** `~/.claude/agents/rue.md`

---

## Problem

The Claude Code tool ecosystem grows: agents, skills, marketplace plugins. The cognitive overhead of maintaining a mental map of what's installed, and then manually invoking the right tool per task, degrades over time. Users have to check, decide, invoke — three steps that should be one.

## Solution

Rue is a head-of-staff agent that owns the tool inventory and routes tasks. It never does work itself — it dispatches to the right specialist and synthesizes results. Natural language triggers Rue automatically; explicit invocation is also supported.

---

## Architecture

### Inventory Cache

`~/.claude/cache/rue-inventory.json` — a compact JSON file rebuilt by Rue when stale.

**TTL:** 24 hours
**Contents:** agents and skills with name, description, trigger keywords
**Rebuild trigger:** missing file or timestamp older than TTL
**Rebuild source:** frontmatter scan of:
- `~/.claude/agents/*.md`
- `~/.claude/skills/*/SKILL.md`
- `~/.claude/plugins/marketplaces/*/skills/*/SKILL.md`
- `.claude/agents/*.md` (project-level, if present)

The cache stores name + description + 4-6 trigger keywords per entry. It never stores full prompts — that would defeat the token efficiency purpose.

### Routing Logic

On task receipt:
1. Check inventory freshness; rebuild if stale
2. Extract intent keywords from user message (domain, action, output)
3. Score inventory entries by keyword overlap
4. Select best-fit agent(s) or skill(s)
5. Choose dispatch pattern (parallel / sequential / direct)
6. If >3 delegations needed, surface plan to user before executing

**Agents vs Skills:** Agents for multi-step, stateful, research-heavy work. Skills for specific workflows (commits, debugging, planning).

### Dispatch

Every subagent prompt includes:
- Specific action (not vague)
- Scope (files, directories, constraints)
- Expected output format
- Done condition

### Synthesis

After each subagent returns, Rue compresses output to 1-3 sentences before carrying it forward. Raw subagent output is never pasted verbatim and never accumulates in Rue's working context.

---

## Design Decisions

**New agent, not a Kim extension.** Kim is a specialist (Claude Code config). Rue is a generalist router. Conflating them would bloat Kim and create confusion about when to use which.

**Hybrid inventory (not static, not always-dynamic).** Static bakes stale data. Always-dynamic costs tokens on every invocation. 24h TTL cache is the right trade-off for a tool ecosystem that changes at most a few times per week.

**Token discipline is first-class.** Orchestrators are vulnerable to context bloat — they accumulate subagent output as they chain. Rue's prompt enforces compression at every step. The "never paste verbatim" rule is the key mechanism.

**Orchestration model is adaptive, not plan-first.** Rue dispatches step-by-step, evaluating after each result. For complex tasks (>3 delegations), it surfaces a plan first so the user stays in control.

---

## Future Enhancements

- **Token-budget-aware refresh:** When approaching context limits but still within subscription window, Rue could proactively rebuild inventory and pre-summarize context before it degrades.
- **Skill invocation:** Currently Rue routes to agents and surfaces skill suggestions. Direct skill invocation (via Skill tool) could be added once routing patterns stabilize.
- **Feedback loop:** Rue could log successful routing decisions to `~/.claude/knowledge/rue-routing-log.md` to improve trigger keyword quality over time.

---

## Related

- Idea 1 (deferred): CC Tool Discovery/Recommendation agent — recommendation-only, no execution. Saved to beads memory.
- Kim agent: `~/.claude/agents/kim.md` — Claude Code config specialist, unchanged.
