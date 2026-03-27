# ccconfig — Claude Code Configuration Management

> **This repo is the proposed canonical home.** See [Consolidation](#consolidation) below.

---

## The Three Repos Problem

Three repos exist for the same purpose — improving the Claude Code system config:

| Repo | Created | Status | Purpose |
|------|---------|--------|---------|
| `up_claude` | Dec 2025 | Historical | Design deliverable for a "workflow optimization agent" |
| `claude-configs` | Dec 2025 | Active but sparse | Meta-repo for config experimentation; born from the claude-mem incident |
| `ccconfig` | Mar 2026 | Newest, most organized | Versioned configs + agent/skill design specs |

---

## What's In Each

### `up_claude` — Design Consultation Deliverable

A one-session package produced when designing what became Kim. Contains:

- **Optimization research** — 5 workflow patterns (context staging, selective tools, prompt hygiene, task decomposition, state management) with token savings estimates
- **15 common mistakes** framework, tiered by impact
- **`kim-evolution/kim.md`** — early Kim agent definition (superseded by current Kim at `~/.claude/agents/kim.md`)
- `KIM_DEVELOPMENT_MASTER_PLAN.md` (1956 lines) — the most complete historical design record
- `AGENT_IMPLEMENTATION_GUIDE.md`, `AGENT_DESIGN_SPEC.md`, case studies, quickstart, etc.

**Verdict:** Mostly superseded. The research is baked into the actual Kim agent and config. Keep as an archive. Only `kim-evolution/kim.md` has marginal reuse value for diffing against current Kim.

---

### `claude-configs` — Operational Config Experimentation Repo

Born from the **claude-mem incident (2025-12-18)**: the plugin burned 1.98M tokens (~$30) creating 521 memory observations with 0% cross-session reuse. Every `Read`/`Grep`/`Glob`/`WebFetch` call triggered a PostToolUse hook that created an observation — codebase explorations generated 95+ observations in 8 minutes.

Contains:

- **`investigations/2025-12-18-claudemem-waste/findings.md`** — the postmortem (keep)
- **`roadmap.md`** — 4-phase optimization roadmap: audit/cleanup → observability → proactive optimization → experimentation framework (keep, still relevant)
- **`plan.md`** — "search first, understand, inventory, observe" philosophy distilled from the incident (keep)
- **`initial-user-request.txt`** — the 6 questions that started everything (archive)
- **`.claude/`** — live Claude Code config: `commands/`, `settings.json`, `settings.local.json`, `CLAUDE.md` (merge into ccconfig)
- **`.mcp.json`** — MCP server definitions: sequential-thinking, filesystem, fetch, memory (evaluate; note: memory MCP is ironic given the incident)
- **`configs/`**, **`docs/`**, **`scripts/`** — all empty (planned but never populated)
- **`claude-viewer/`** — a viewer tool (evaluate)

**Verdict:** Has the best narrative context (the incident, the lessons, the roadmap) and some live config. Directories are mostly empty stubs matching what ccconfig already has. Merge the docs and `.claude/` content in; discard the empty structure.

---

### `ccconfig` — This Repo (Canonical Going Forward)

Contains:

- **`AGENTS.md`** — peer-reviewed specs for three agents:
  1. **Context Window Inspector** (skill) — reconstructs what's in context from disk, estimates token cost, flags staleness/redundancy. Technically sound: acknowledges Claude has no programmatic context access, uses character-count heuristics labeled as estimates.
  2. **Kim Agent** — completed. Reduced from 451→162 lines. Backup at `configs/baseline/agents/kim.md`. Changes documented.
  3. **Config Cleaner** (agent) — detects stale references, duplicate instructions, missing binaries, oversized agents, orphaned files. Report-only, no modifications.
- **`CLAUDE.md`** — detailed project instructions covering architecture, workflows, testing philosophy, metrics categories
- **`configs/`** — versioned config sets (baseline, experimental, production)

**Verdict:** The most organized and up-to-date. Should be canonical.

---

## Consolidation

Migrated. **This is now the canonical repo.** Both source repos can be archived.

### Migrated from `claude-configs`

| Source | Destination | Notes |
|--------|-------------|-------|
| `investigations/` | `investigations/` | Claudemem incident postmortem |
| `roadmap.md` | `docs/roadmap.md` | 4-phase optimization roadmap |
| `plan.md` | `docs/philosophy.md` | Core principles distilled from the incident |
| `.claude/settings.json` | `configs/reference/settings.json` | Plugin config reference example |
| `.claude/settings.local.json` | `configs/reference/settings.local.json` | Permissions/MCP reference example |
| `.mcp.json` | `configs/reference/mcp.json` | MCP server definitions reference |
| `claude-viewer/` | `tools/claude-viewer/` | Conversation history viewer with MCP integration |
| `.claude/commands/cluddha.md` | — | Skipped — thin wrapper for global agent |
| Empty `configs/`, `docs/`, `scripts/` | — | Skipped — structure already exists here |

### Migrated from `up_claude`

| Source | Destination | Notes |
|--------|-------------|-------|
| `kim-evolution/kim.md` | `docs/kim-history.md` | Early Kim definition, useful for diffing |
| `CANDIDATES.md` | `docs/ecosystem-catalog.md` | Community catalog of plugin marketplaces, MCP servers, agents, skills |
| Everything else | — | Superseded by actual implementation |

### Archive commands

```bash
mv ~/proj/up_claude ~/proj/_archive/up_claude
mv ~/proj/claude-configs ~/proj/_archive/claude-configs
```

---

## Current Priorities

From the consolidated roadmap, the open work:

1. **Context Window Inspector skill** — spec in `AGENTS.md`, not yet built
2. **Config Cleaner agent** — spec in `AGENTS.md`, not yet built
3. **Observability** — lightweight token usage tracking (roadmap Phase 2), no implementation yet
4. **Config profiles** — `configs/` structure exists, no profiles yet populated

---

## Key Lesson (from the claude-mem Incident)

> "Memory systems need clear ROI measurement and project-scoped context. Global context injection from unrelated projects = pure waste. Search for existing solutions before building. Observe without creating overhead."

This principle shapes every decision in this repo: measure before optimizing, pull-based visibility not push-based monitoring, and treat configs as code — version control, test, iterate.
