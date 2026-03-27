# AGENTS.md

Detailed specifications for agents and skills to be built in this project. Each section describes purpose, responsibilities, implementation form (agent vs skill), and integration points.

Reviewed by three independent agents (Kim self-review, architectural review, adversarial research review). Findings consolidated below.

---

## 1. Context Window Inspector

### Form: Skill (not agent)

A skill is correct — not because it can "see" the context window (it can't), but because it's lighter weight than a subagent and the work is a guided sequence of file reads in the main conversation.

### Technical Reality

Claude has no programmatic access to its own context window contents or token usage. GitHub issues #36678 and #34879 document this as an open feature request. The skill therefore uses a **reconstructive inventory** approach: it reads the source files from disk that Claude Code assembles into the context, and estimates what the resulting context looks like.

This means:
- Token counts are **estimates** based on character count heuristics (~4 chars per token). Must be labeled as estimates, not measurements.
- The skill itself injects its SKILL.md content into context when invoked, inflating the measurement (observer effect). The report should note this.
- Some injected content (system reminders, deferred tool lists) cannot be reconstructed from files — the skill can only report on what it can read from disk.

### What It Reconstructs

The skill reads and analyzes these source files:

- **Global CLAUDE.md** (`~/.claude/CLAUDE.md`) — read file, estimate tokens
- **Project CLAUDE.md** (`.claude/CLAUDE.md` and `./CLAUDE.md`) — read files, estimate tokens
- **@-includes** — parse `@filename` references in CLAUDE.md files, follow them transitively, report full inclusion tree and cumulative size
- **MCP server configs** — read `settings.json` / `.mcp.json` to identify configured servers. Cannot read the actual injected instruction text, but can list servers and flag ones with many tools (high token cost). Note: MCP servers can consume 50-143K tokens at startup — this is often the largest context cost.
- **Memory index** (`MEMORY.md`) — read if it exists (may not exist in all setups)
- **Git status** — minor fixed overhead, note but don't analyze

### Analysis Dimensions

For each reconstructable source:

1. **Estimated token count** — character-based heuristic, clearly labeled as estimate
2. **Staleness** — references to files/paths/tools that don't exist on disk
3. **Redundancy** — content repeated across multiple sources (e.g., same instructions in global and project CLAUDE.md)
4. **Relevance to current project** — global instructions that reference project-specific paths/tools (advisory — this is subjective and quality will vary)
5. **Actionability** — instructions referencing tools, workflows, or files that don't exist

### Output

A structured report with:
- Inventory table: source, estimated tokens, staleness/redundancy flags
- Total estimated context overhead before the first user message
- MCP server count and estimated tool overhead (flagged as major cost if >3 servers)
- Ranked list of improvement suggestions (largest token savings first)
- Specific items to move, remove, consolidate, or make project-specific

### What It Does NOT Do

- Does not modify any files (analysis only — user decides what to act on)
- Does not measure actual token usage (no API for this)
- Does not read MCP server instruction text (injected by Claude Code, not accessible from disk)
- Does not inspect plugin caches or marketplace content

---

## 2. Kim Agent — Completed

**Status: Done.** Kim was reduced from 451 to 162 lines. Backup saved at `configs/baseline/agents/kim.md`.

Changes applied:
- Removed TodoWrite from tools (aligned with user's `bd` preference)
- Removed delegation model, one of three examples (Config Audit), error handling templates, learning loop template, work style summary, closing line
- Kept and tightened: 7-step execution protocol, two condensed examples (agent creation + workflow evaluation), boundaries, 3 pre-completion checks, 3 named error categories
- lessons-learned.md reference verified active (24KB, entries through 2026-02-24) and preserved as one-line reference
- Removed stale "January 2025" knowledge date, replaced with behavioral instruction

Verified: Kim produces format-compliant structured output on test task post-cleanup.

---

## 3. Config Cleaner

### Form: Agent

An agent is appropriate — independent analytical work reading files from disk, can be dispatched while user continues other work.

### Purpose

Detect and report stale, wasteful, or broken elements in Claude Code configuration. Focused specifically on finding things to remove or fix.

### Scope

**Scan (allowlist approach):**
- `~/.claude/agents/` — agent definitions
- `~/.claude/skills/` — skill directories
- `~/.claude/commands/` — slash commands
- `~/.claude/conventions/` — convention files (if present)
- `~/.claude/knowledge/` — knowledge files
- `~/.claude/hooks/` — hook scripts
- `~/.claude/CLAUDE.md` — global instructions
- `~/.claude/settings.json`, `~/.claude/settings.local.json` — settings
- `~/.claude/.mcp.json` — MCP config (if present)
- `~/.claude/projects/*/MEMORY.md` — memory indexes
- `.claude/` — current project config (if present)

**Also audit (report-only, no modifications):**
- MCP server configurations — list configured servers, flag those that may be contributing significant context overhead. MCP servers are documented as the single largest source of context bloat (50-143K tokens). Ignoring them would make the cleaner ineffective at addressing the biggest problem.
- Plugin install state — check if configured MCP servers' binaries exist on PATH. Flag missing binaries (causes silent timeout errors per GitHub issue #18762).

**Skip entirely:**
- `~/.claude/plugins/cache/` — managed by plugin system
- `~/.claude/plugins/marketplaces/` — third-party content
- `~/.claude/statsig/`, `~/.claude/telemetry/`, `~/.claude/cache/` — runtime state
- `~/.claude/sessions/`, `~/.claude/ide/` — managed by Claude Code

### What It Detects

#### Stale Content (fully automatable)
- **Dead file references** — CLAUDE.md mentions files that don't exist
- **Broken @-includes** — `@filename` references to missing files
- **@-include chain size** — trace the full transitive inclusion tree and report total cumulative size (large chains create unexpected context overhead)
- **Old dates and TODOs** — "TODO" items or date references more than 3 months old that were likely forgotten
- **Agent definitions over 300 lines** — flag for review
- **Skill directories missing SKILL.md** — directories under skills/ that lack the required file

#### Stale Content (best-effort, may have false positives)
- **Outdated URLs** — can check for 404s but cannot detect content that moved without breaking the link. Labeled as "best-effort" in output.
- **References to removed tools** — check tool names in agent definitions against known Claude Code tool set. Requires maintaining a reference list, so may lag behind actual changes.

#### Overhead Without Value
- **Duplicate instructions** — same rule or convention stated in multiple places. This is semantic comparison (LLM strength), but findings are labeled as "candidates" requiring user judgment.
- **Memory entries that contradict current state** — memory files referencing files/paths that no longer exist
- **MCP servers with missing binaries** — configured but binary not on PATH (causes silent timeout failures)
- **Conflicting settings** — `settings.json` and `settings.local.json` with contradictory values for the same key

#### Orphaned Files
- **Agent .md files not in agents/** — markdown with agent-like YAML frontmatter outside the correct directory
- **Hooks referencing nonexistent scripts** — hook configurations pointing to executables that don't exist
- **Config files for systems no longer installed** — e.g., MCP server configs where the server binary is missing

### Output

Structured report organized by severity:

- **Remove** — files/references that are clearly dead and serve no purpose
- **Review** — items that might be stale but need user judgment (includes all "best-effort" detections and semantic duplicate candidates)
- **Consolidate** — duplicate content that could be merged

Each finding includes: what was found, where, why it appears to be an issue, and suggested action.

### What It Does NOT Do

- Does not delete or modify anything — report only
- Does not analyze session data or usage patterns (that's the Session Analyzer's job)
- Does not research Claude Code docs for new features (that's the self-audit skill's monthly refresh)
- Does not modify plugin/marketplace content (report-only for MCP audit)

### Relationship to Existing Components

- **Replaces self-audit skill phases 1-5** — Config Cleaner provides more thorough detection for config inventory, agent quality, skill review, convention compliance, and documentation currency. Self-audit should invoke Config Cleaner rather than reimplementing.
- **Kim delegates audit tasks here** — Kim's config audit example was removed during cleanup. Config Cleaner is now the dedicated audit agent.
- **Complements Context Window Inspector** — Inspector analyzes estimated context load. Config Cleaner analyzes what's on disk. Together they cover both perspectives.

---

## 4. Session Analyzer

### Form: Revised — extraction script + single analytical agent

The original three-agent pipeline was reviewed and found to be over-engineered for this use case:

- Research (arXiv 2601.04748, "When Single-Agent with Skills Replace Multi-Agent Systems") shows single agents match multi-agent performance for sequential, analytical, read-only tasks while cutting token cost ~3x.
- The data extraction phase is mechanical (parse JSONL, filter by date, extract fields) — deterministic work that doesn't need LLM reasoning.
- Real session data measured at 145MB / 73 sessions for one project, with individual files up to 14MB. An LLM agent cannot reliably process this volume.
- Sequential pipeline with no parallelism opportunity means each agent handoff adds cost with no quality gain.

**Revised architecture:**

```
User request (time range, quantity limit)
    │
    ▼
[Python script: session-extractor.py]
    │ writes: /tmp/session-analysis-<timestamp>.json
    ▼
[Agent: Session Analyzer]
    │ reads extracted data, analyzes patterns, produces report
    ▼
Report delivered to user
```

### Scope and Limits

- **Time range**: configurable from 1 week to 1 month of sessions
- **Quantity limit**: cap on number of sessions (user-specified, default 30)
- **Source**: Claude Code session JSONL files from `~/.claude/projects/`
- **Project scope**: must specify per-project or cross-project analysis (different patterns emerge from each)

### Extraction Script: `scripts/session-extractor.py`

Python script (not an LLM agent) that handles the mechanical data work.

**Process:**
1. Enumerate session JSONL files within the time range, sorted by recency, capped at quantity limit
2. For each session, extract:
   - Session metadata: project path, start time, duration, total turns
   - User messages: full prompt text (essential for pattern detection), truncated at ~2000 chars per message to control output size
   - Tool usage: which tools called, how many times, success/failure counts
   - Token counts: input/output tokens per turn (if present in session data)
   - Errors and retries: tool calls that failed, were denied, or were retried
   - Conversation flow markers: user corrections, repeated requests
3. Write structured JSON to temp file

**JSONL format handling:**
- Entry types: `system`, `user`, `assistant`, `progress` — filter to `user` and `assistant` for analysis
- Skip `thinking` blocks (encrypted signatures, no useful text)
- Skip `progress` entries (hook events, noise for analysis)
- Summarize `tool_result` entries (can contain full file contents — extract only tool name, success/failure, result size)
- Handle nested `message.content` that can be string or array of objects

**Output**: JSON file small enough for the analytical agent's context (~100K tokens max for the full batch).

### Agent: Session Analyzer

Single agent that reads the extracted data and performs both pattern detection and report generation. Three clearly delimited sections in its prompt guide the workflow.

**Detection Categories:**

**Repeating Patterns**
- Same or similar prompts across multiple sessions (user re-explaining things that should be in CLAUDE.md or memory)
- Same correction given repeatedly (indicates missing instruction or convention)
- Recurring context recovery sequences (time spent re-establishing context between sessions)

**Productivity Blockers**
- Permission denials that required re-prompting (candidates for allow-listing in settings)
- Multi-turn correction loops (Claude does X, user says "no, do Y" — indicates unclear instructions)
- Abandoned approaches (Claude starts one path, user redirects — misalignment in guidance)

**Token Waste**
- Verbose tool usage where simpler approaches existed
- Large file reads immediately followed by focused re-reads
- Repeated reads of the same file within a session
- Excessively long responses the user didn't engage with

**Time Consumers**
- Long tool call sequences for parallelizable tasks
- Research spirals (many searches without converging)
- Sessions with high turn counts relative to work accomplished

**Confidence Thresholds (severity-tiered, not flat):**

The original spec required 3+ sessions for all findings. This was found to be too conservative — it would suppress catastrophic one-off events (e.g., a single session where MCP servers consumed 180K of 200K context tokens).

Revised:
- **High-severity findings** (context blowouts, complete agent failures, infinite loops): report on 1+ occurrences
- **Medium-severity findings** (correction loops, abandoned approaches): report on 2+ occurrences
- **Low-severity findings** (minor inefficiencies, slight redundancies): report on 3+ occurrences

**Report Output:**

```
# Session Analysis Report
## Period: [date range], [N] sessions analyzed

## Executive Summary
[2-3 sentences: biggest findings, overall health assessment]

## High-Confidence Findings

### Finding 1: [descriptive title]
**Impact**: [high/medium] | **Frequency**: [N/M sessions]
**What's happening**: [clear description with specific examples from sessions]
**Suggested fix**: [specific, actionable recommendation]
**Where to change**: [exact file path and what to add/modify]

### Finding 2: ...

## Additional Observations
[Medium-confidence patterns noted for awareness but not recommended for action yet.
These become high-confidence if they persist in the next analysis.]

## Excluded
[N findings below confidence threshold — will be promoted if they recur in next analysis.]

## Metrics Summary
- Sessions analyzed: N
- Time period: [range]
- Total user prompts: N
- Patterns detected: N (X high-confidence, Y medium-confidence)
```

**Report Quality Rules:**
- Every suggestion must reference specific files to change and what to add/modify
- No speculative improvements — every suggestion grounded in observed session evidence
- Prioritize by estimated impact (largest token/time savings first)
- "Write better prompts" is not actionable; "add this instruction to CLAUDE.md: [exact text]" is

### Data Passing Convention

Stages communicate via temporary files, not through parent conversation context:
- Extraction script writes to `/tmp/session-analysis-<timestamp>.json`
- Agent reads this file via Read tool
- Final report delivered directly to user as agent output
- Previous analysis results (for trend comparison) stored at `~/.claude/knowledge/session-analysis-latest.json`

### Relationship to Existing Components

- **vibe-log agents** — focus on productivity reporting (what was accomplished, activity distribution). Session Analyzer focuses on finding inefficiencies and suggesting config improvements. Different goals, may share extraction code.
- **self-audit skill** — examines config quality statically. Session Analyzer examines how config performs in practice. Complementary: self-audit finds what looks wrong; Session Analyzer finds what actually causes problems in use.

---

## Implementation Priority

Revised based on review findings:

1. **Kim Agent cleanup** — done. Quick win, immediate token savings.
2. **Config Cleaner** — next. Low risk, high leverage. Cleans the largest overhead sources (including MCP audit) before other tools measure or analyze.
3. **Context Window Inspector** — after Config Cleaner. Uses reconstructive approach (reads source files). Benefits from Config Cleaner having already removed dead references.
4. **Session Analyzer** — last. Most complex (script + agent). Needs accumulated session data to be useful. Benefits from all other improvements being in place so measurements reflect the improved config.

Note: Chris (adversarial review) argued Session Analyzer should come first to establish a measurement baseline. This is valid for a research-oriented workflow. The current ordering prioritizes quick wins and reducing known waste before measuring.
# AGENTS.md

Detailed specifications for agents and skills to be built in this project. Each section describes purpose, responsibilities, implementation form (agent vs skill), and integration points.

Reviewed by three independent agents (Kim self-review, architectural review, adversarial research review). Findings consolidated below.

---

## 1. Context Window Inspector

### Form: Skill (not agent)

A skill is correct — not because it can "see" the context window (it can't), but because it's lighter weight than a subagent and the work is a guided sequence of file reads in the main conversation.

### Technical Reality

Claude has no programmatic access to its own context window contents or token usage. GitHub issues #36678 and #34879 document this as an open feature request. The skill therefore uses a **reconstructive inventory** approach: it reads the source files from disk that Claude Code assembles into the context, and estimates what the resulting context looks like.

This means:
- Token counts are **estimates** based on character count heuristics (~4 chars per token). Must be labeled as estimates, not measurements.
- The skill itself injects its SKILL.md content into context when invoked, inflating the measurement (observer effect). The report should note this.
- Some injected content (system reminders, deferred tool lists) cannot be reconstructed from files — the skill can only report on what it can read from disk.

### What It Reconstructs

The skill reads and analyzes these source files:

- **Global CLAUDE.md** (`~/.claude/CLAUDE.md`) — read file, estimate tokens
- **Project CLAUDE.md** (`.claude/CLAUDE.md` and `./CLAUDE.md`) — read files, estimate tokens
- **@-includes** — parse `@filename` references in CLAUDE.md files, follow them transitively, report full inclusion tree and cumulative size
- **MCP server configs** — read `settings.json` / `.mcp.json` to identify configured servers. Cannot read the actual injected instruction text, but can list servers and flag ones with many tools (high token cost). Note: MCP servers can consume 50-143K tokens at startup — this is often the largest context cost.
- **Memory index** (`MEMORY.md`) — read if it exists (may not exist in all setups)
- **Git status** — minor fixed overhead, note but don't analyze

### Analysis Dimensions

For each reconstructable source:

1. **Estimated token count** — character-based heuristic, clearly labeled as estimate
2. **Staleness** — references to files/paths/tools that don't exist on disk
3. **Redundancy** — content repeated across multiple sources (e.g., same instructions in global and project CLAUDE.md)
4. **Relevance to current project** — global instructions that reference project-specific paths/tools (advisory — this is subjective and quality will vary)
5. **Actionability** — instructions referencing tools, workflows, or files that don't exist

### Output

A structured report with:
- Inventory table: source, estimated tokens, staleness/redundancy flags
- Total estimated context overhead before the first user message
- MCP server count and estimated tool overhead (flagged as major cost if >3 servers)
- Ranked list of improvement suggestions (largest token savings first)
- Specific items to move, remove, consolidate, or make project-specific

### What It Does NOT Do

- Does not modify any files (analysis only — user decides what to act on)
- Does not measure actual token usage (no API for this)
- Does not read MCP server instruction text (injected by Claude Code, not accessible from disk)
- Does not inspect plugin caches or marketplace content

---

## 2. Kim Agent — Completed

**Status: Done.** Kim was reduced from 451 to 162 lines. Backup saved at `configs/baseline/agents/kim.md`.

Changes applied:
- Removed TodoWrite from tools (aligned with user's `bd` preference)
- Removed delegation model, one of three examples (Config Audit), error handling templates, learning loop template, work style summary, closing line
- Kept and tightened: 7-step execution protocol, two condensed examples (agent creation + workflow evaluation), boundaries, 3 pre-completion checks, 3 named error categories
- lessons-learned.md reference verified active (24KB, entries through 2026-02-24) and preserved as one-line reference
- Removed stale "January 2025" knowledge date, replaced with behavioral instruction

Verified: Kim produces format-compliant structured output on test task post-cleanup.

---

## 3. Config Cleaner

### Form: Agent

An agent is appropriate — independent analytical work reading files from disk, can be dispatched while user continues other work.

### Purpose

Detect and report stale, wasteful, or broken elements in Claude Code configuration. Focused specifically on finding things to remove or fix.

### Scope

**Scan (allowlist approach):**
- `~/.claude/agents/` — agent definitions
- `~/.claude/skills/` — skill directories
- `~/.claude/commands/` — slash commands
- `~/.claude/conventions/` — convention files (if present)
- `~/.claude/knowledge/` — knowledge files
- `~/.claude/hooks/` — hook scripts
- `~/.claude/CLAUDE.md` — global instructions
- `~/.claude/settings.json`, `~/.claude/settings.local.json` — settings
- `~/.claude/.mcp.json` — MCP config (if present)
- `~/.claude/projects/*/MEMORY.md` — memory indexes
- `.claude/` — current project config (if present)

**Also audit (report-only, no modifications):**
- MCP server configurations — list configured servers, flag those that may be contributing significant context overhead. MCP servers are documented as the single largest source of context bloat (50-143K tokens). Ignoring them would make the cleaner ineffective at addressing the biggest problem.
- Plugin install state — check if configured MCP servers' binaries exist on PATH. Flag missing binaries (causes silent timeout errors per GitHub issue #18762).

**Skip entirely:**
- `~/.claude/plugins/cache/` — managed by plugin system
- `~/.claude/plugins/marketplaces/` — third-party content
- `~/.claude/statsig/`, `~/.claude/telemetry/`, `~/.claude/cache/` — runtime state
- `~/.claude/sessions/`, `~/.claude/ide/` — managed by Claude Code

### What It Detects

#### Stale Content (fully automatable)
- **Dead file references** — CLAUDE.md mentions files that don't exist
- **Broken @-includes** — `@filename` references to missing files
- **@-include chain size** — trace the full transitive inclusion tree and report total cumulative size (large chains create unexpected context overhead)
- **Old dates and TODOs** — "TODO" items or date references more than 3 months old that were likely forgotten
- **Agent definitions over 300 lines** — flag for review
- **Skill directories missing SKILL.md** — directories under skills/ that lack the required file

#### Stale Content (best-effort, may have false positives)
- **Outdated URLs** — can check for 404s but cannot detect content that moved without breaking the link. Labeled as "best-effort" in output.
- **References to removed tools** — check tool names in agent definitions against known Claude Code tool set. Requires maintaining a reference list, so may lag behind actual changes.

#### Overhead Without Value
- **Duplicate instructions** — same rule or convention stated in multiple places. This is semantic comparison (LLM strength), but findings are labeled as "candidates" requiring user judgment.
- **Memory entries that contradict current state** — memory files referencing files/paths that no longer exist
- **MCP servers with missing binaries** — configured but binary not on PATH (causes silent timeout failures)
- **Conflicting settings** — `settings.json` and `settings.local.json` with contradictory values for the same key

#### Orphaned Files
- **Agent .md files not in agents/** — markdown with agent-like YAML frontmatter outside the correct directory
- **Hooks referencing nonexistent scripts** — hook configurations pointing to executables that don't exist
- **Config files for systems no longer installed** — e.g., MCP server configs where the server binary is missing

### Output

Structured report organized by severity:

- **Remove** — files/references that are clearly dead and serve no purpose
- **Review** — items that might be stale but need user judgment (includes all "best-effort" detections and semantic duplicate candidates)
- **Consolidate** — duplicate content that could be merged

Each finding includes: what was found, where, why it appears to be an issue, and suggested action.

### What It Does NOT Do

- Does not delete or modify anything — report only
- Does not analyze session data or usage patterns (that's the Session Analyzer's job)
- Does not research Claude Code docs for new features (that's the self-audit skill's monthly refresh)
- Does not modify plugin/marketplace content (report-only for MCP audit)

### Relationship to Existing Components

- **Replaces self-audit skill phases 1-5** — Config Cleaner provides more thorough detection for config inventory, agent quality, skill review, convention compliance, and documentation currency. Self-audit should invoke Config Cleaner rather than reimplementing.
- **Kim delegates audit tasks here** — Kim's config audit example was removed during cleanup. Config Cleaner is now the dedicated audit agent.
- **Complements Context Window Inspector** — Inspector analyzes estimated context load. Config Cleaner analyzes what's on disk. Together they cover both perspectives.

---

## 4. Session Analyzer

### Form: Revised — extraction script + single analytical agent

The original three-agent pipeline was reviewed and found to be over-engineered for this use case:

- Research (arXiv 2601.04748, "When Single-Agent with Skills Replace Multi-Agent Systems") shows single agents match multi-agent performance for sequential, analytical, read-only tasks while cutting token cost ~3x.
- The data extraction phase is mechanical (parse JSONL, filter by date, extract fields) — deterministic work that doesn't need LLM reasoning.
- Real session data measured at 145MB / 73 sessions for one project, with individual files up to 14MB. An LLM agent cannot reliably process this volume.
- Sequential pipeline with no parallelism opportunity means each agent handoff adds cost with no quality gain.

**Revised architecture:**

```
User request (time range, quantity limit)
    │
    ▼
[Python script: session-extractor.py]
    │ writes: /tmp/session-analysis-<timestamp>.json
    ▼
[Agent: Session Analyzer]
    │ reads extracted data, analyzes patterns, produces report
    ▼
Report delivered to user
```

### Scope and Limits

- **Time range**: configurable from 1 week to 1 month of sessions
- **Quantity limit**: cap on number of sessions (user-specified, default 30)
- **Source**: Claude Code session JSONL files from `~/.claude/projects/`
- **Project scope**: must specify per-project or cross-project analysis (different patterns emerge from each)

### Extraction Script: `scripts/session-extractor.py`

Python script (not an LLM agent) that handles the mechanical data work.

**Process:**
1. Enumerate session JSONL files within the time range, sorted by recency, capped at quantity limit
2. For each session, extract:
   - Session metadata: project path, start time, duration, total turns
   - User messages: full prompt text (essential for pattern detection), truncated at ~2000 chars per message to control output size
   - Tool usage: which tools called, how many times, success/failure counts
   - Token counts: input/output tokens per turn (if present in session data)
   - Errors and retries: tool calls that failed, were denied, or were retried
   - Conversation flow markers: user corrections, repeated requests
3. Write structured JSON to temp file

**JSONL format handling:**
- Entry types: `system`, `user`, `assistant`, `progress` — filter to `user` and `assistant` for analysis
- Skip `thinking` blocks (encrypted signatures, no useful text)
- Skip `progress` entries (hook events, noise for analysis)
- Summarize `tool_result` entries (can contain full file contents — extract only tool name, success/failure, result size)
- Handle nested `message.content` that can be string or array of objects

**Output**: JSON file small enough for the analytical agent's context (~100K tokens max for the full batch).

### Agent: Session Analyzer

Single agent that reads the extracted data and performs both pattern detection and report generation. Three clearly delimited sections in its prompt guide the workflow.

**Detection Categories:**

**Repeating Patterns**
- Same or similar prompts across multiple sessions (user re-explaining things that should be in CLAUDE.md or memory)
- Same correction given repeatedly (indicates missing instruction or convention)
- Recurring context recovery sequences (time spent re-establishing context between sessions)

**Productivity Blockers**
- Permission denials that required re-prompting (candidates for allow-listing in settings)
- Multi-turn correction loops (Claude does X, user says "no, do Y" — indicates unclear instructions)
- Abandoned approaches (Claude starts one path, user redirects — misalignment in guidance)

**Token Waste**
- Verbose tool usage where simpler approaches existed
- Large file reads immediately followed by focused re-reads
- Repeated reads of the same file within a session
- Excessively long responses the user didn't engage with

**Time Consumers**
- Long tool call sequences for parallelizable tasks
- Research spirals (many searches without converging)
- Sessions with high turn counts relative to work accomplished

**Confidence Thresholds (severity-tiered, not flat):**

The original spec required 3+ sessions for all findings. This was found to be too conservative — it would suppress catastrophic one-off events (e.g., a single session where MCP servers consumed 180K of 200K context tokens).

Revised:
- **High-severity findings** (context blowouts, complete agent failures, infinite loops): report on 1+ occurrences
- **Medium-severity findings** (correction loops, abandoned approaches): report on 2+ occurrences
- **Low-severity findings** (minor inefficiencies, slight redundancies): report on 3+ occurrences

**Report Output:**

```
# Session Analysis Report
## Period: [date range], [N] sessions analyzed

## Executive Summary
[2-3 sentences: biggest findings, overall health assessment]

## High-Confidence Findings

### Finding 1: [descriptive title]
**Impact**: [high/medium] | **Frequency**: [N/M sessions]
**What's happening**: [clear description with specific examples from sessions]
**Suggested fix**: [specific, actionable recommendation]
**Where to change**: [exact file path and what to add/modify]

### Finding 2: ...

## Additional Observations
[Medium-confidence patterns noted for awareness but not recommended for action yet.
These become high-confidence if they persist in the next analysis.]

## Excluded
[N findings below confidence threshold — will be promoted if they recur in next analysis.]

## Metrics Summary
- Sessions analyzed: N
- Time period: [range]
- Total user prompts: N
- Patterns detected: N (X high-confidence, Y medium-confidence)
```

**Report Quality Rules:**
- Every suggestion must reference specific files to change and what to add/modify
- No speculative improvements — every suggestion grounded in observed session evidence
- Prioritize by estimated impact (largest token/time savings first)
- "Write better prompts" is not actionable; "add this instruction to CLAUDE.md: [exact text]" is

### Data Passing Convention

Stages communicate via temporary files, not through parent conversation context:
- Extraction script writes to `/tmp/session-analysis-<timestamp>.json`
- Agent reads this file via Read tool
- Final report delivered directly to user as agent output
- Previous analysis results (for trend comparison) stored at `~/.claude/knowledge/session-analysis-latest.json`

### Relationship to Existing Components

- **vibe-log agents** — focus on productivity reporting (what was accomplished, activity distribution). Session Analyzer focuses on finding inefficiencies and suggesting config improvements. Different goals, may share extraction code.
- **self-audit skill** — examines config quality statically. Session Analyzer examines how config performs in practice. Complementary: self-audit finds what looks wrong; Session Analyzer finds what actually causes problems in use.

---

## Implementation Priority

Revised based on review findings:

1. **Kim Agent cleanup** — done. Quick win, immediate token savings.
2. **Config Cleaner** — next. Low risk, high leverage. Cleans the largest overhead sources (including MCP audit) before other tools measure or analyze.
3. **Context Window Inspector** — after Config Cleaner. Uses reconstructive approach (reads source files). Benefits from Config Cleaner having already removed dead references.
4. **Session Analyzer** — last. Most complex (script + agent). Needs accumulated session data to be useful. Benefits from all other improvements being in place so measurements reflect the improved config.

Note: Chris (adversarial review) argued Session Analyzer should come first to establish a measurement baseline. This is valid for a research-oriented workflow. The current ordering prioritizes quick wins and reducing known waste before measuring.

