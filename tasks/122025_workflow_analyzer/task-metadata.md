# Task Metadata: Workflow Analyzer Agent

**Codename:** workflow_analyzer
**Date:** 2025-12-20
**Status:** Completed

## Objective
Design specification and architecture for a Claude Code workflow analysis agent that identifies underutilized capabilities and suggests workflow optimizations.

## Deliverables
- [x] Agent specification document (workflow-analyzer-spec.md - 50 pages)
- [x] Architecture design (architecture.md - 23 pages)
- [x] Deployment guide (deployment-guide.md - 19 pages)
- [x] Executive summary (summary.md)
- [ ] Example agent markdown file (deferred to implementation task)

## Context
Scout ecosystem search revealed existing tools (Claude Viewer, History MCP) provide token tracking and basic analytics, but none offer:
- Comparison of used vs available tools/agents/commands
- Workflow inefficiency detection
- Proactive suggestions for underutilized capabilities

User requirement: Post-hoc, pull-based analysis with zero monitoring overhead.

## Outcome

**Designed:** Workflow Analyzer - stateless pull-based analysis agent

**Key Features:**
- Scans available capabilities vs actual usage from history.jsonl
- Detects 4 major inefficiency patterns (manual exploration, repeated searches, manual git, complex reasoning)
- Recommends unused tools that match workflow patterns
- Zero runtime overhead (post-hoc analysis only)
- ~30 second execution, ~15k tokens per analysis

**Architecture:**
- 5-component pipeline: Inventory Scanner → History Parser → Usage Analyzer → Pattern Detector → Recommendation Engine
- Heuristic-based detection (transparent, tunable rules)
- Generates actionable markdown reports with effort/impact estimates

**Implementation Approach:**
- Agent (not MCP) - simplest, no dependencies
- Uses built-in Claude Code tools (Read, Glob, Grep, Bash/jq)
- Single file: ~/.claude/agents/workflow-analyzer.md
- Estimated build time: 3-4 hours

**Why This Solves The Problem:**
- Fills ecosystem gap (Scout confirmed nothing exists)
- Aligns with plan.md philosophy (pull-based, zero overhead)
- Provides 80% of roadmap.md value with 20% complexity
- Actionable recommendations vs just metrics

**Next Step:** Implement workflow-analyzer.md agent file (separate task)
