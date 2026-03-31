# History and Lineage

This repository exists because several related efforts converged into one problem: reusable workflow content had value, but the surrounding narratives, experiments, and packaging ideas had become scattered across too many surfaces.

## The Incident That Changed Direction

The strongest turning point was the 2025-12-18 claude-mem overhead investigation.

The practical lessons that survived that investigation are:

- measure overhead before adding automation
- prefer pull-based visibility to always-on monitoring
- search for existing tools before building new ones
- treat repeated configuration and workflow advice as reusable assets, not one-off chat history

Those principles are still active. The raw evidence remains in:

- `investigations/2025-12-18-claudemem-waste/findings.md`
- `docs/roadmap.md`
- `docs/philosophy.md`
- `initial-user-request.txt`

## Three Source Threads That Converged Here

### 1. Config optimization and observability work

This thread produced:

- the claude-mem postmortem
- the observability and cleanup roadmap
- the “search first / pull-based analysis” philosophy

It explains why the repo now favors reusable skills and compact design guidance over ambitious always-on systems.

### 2. Agent design and evolution work

This thread produced:

- Kim’s early design material
- more structured agent specs
- comparative reviews of agent prompt shape and tool scope

The enduring outcome is that agent behavior should be kept compact, task-specific, and honest about runtime boundaries.

Primary source material:

- `docs/kim-history.md`
- `agents/kim.md`
- `up_claude/kim-evolution/kim.md`
- `up_claude/KIM_DEVELOPMENT_MASTER_PLAN.md`

### 3. Ecosystem discovery and workflow simplification

This thread produced:

- Scout as the “search before build” agent
- Workflow Analyzer as a simpler, pull-based observability direction
- a more explicit distinction between reusable content and runtime adapters

Primary source material:

- `tasks/121825_scout_agent/*`
- `tasks/122025_workflow_analyzer/*`
- `docs/ecosystem-catalog.md`
- `agents/scout.md`

## Why the Repo Needed Cleanup

The repo accumulated several overlapping narratives:

- “configuration management system”
- “agent design lab”
- “historical consultation archive”
- “catalog of installable skills and agents”

All four left traces in the tree. The cleanup does not erase that history; it compacts it so the current repo purpose is obvious:

- `skills/` are the reusable center
- Claude agents are runtime adapters
- Codex support should be skills plus plugins
- older design material is retained as source material rather than front-door documentation

## Treatment of Older Surfaces

### `up_claude/`

`up_claude/` is retained as source-only archive material from an earlier design phase. It still contains useful context, but it should no longer be treated as an active product entrypoint.

### `tasks/`

The task packets are retained selectively because some of them still contain useful implementation detail, especially:

- `121825_scout_agent`
- `122025_workflow_analyzer`

The older testing methodology packet remains as historical design material and should be referenced only when that direction becomes active again.

### legacy docs under `docs/`

Files such as `roadmap.md`, `philosophy.md`, `agent-design-specs.md`, and `agent-dotfiles-diff-notes.md` remain useful as source material, but the canonical current guidance is now concentrated in the four main docs.

## What Survived the Cleanup

The high-value through-lines intentionally preserved are:

- the claude-mem lesson
- Kim’s evolution
- Scout’s “search before build” stance
- Workflow Analyzer as the simplified observability path
- the emerging split between portable skills and runtime-specific adapters

## Provenance

This document condenses content from:

- `investigations/2025-12-18-claudemem-waste/findings.md`
- `docs/roadmap.md`
- `docs/philosophy.md`
- `docs/kim-history.md`
- `docs/ecosystem-catalog.md`
- `tasks/121825_scout_agent/*`
- `tasks/122025_workflow_analyzer/*`
- `up_claude/*`
