---
name: context-window-inspector
description: Use when estimating context window overhead in Claude Code configurations, auditing token consumption, identifying configuration bloat, or answering questions like "how many tokens left?", "check my context window", "what's eating my tokens?", or "audit Claude Code configuration".
---

# Context Window Inspector

This skill performs a **reconstructive inventory** of the files that Claude Code assembles into its context window, providing estimated token counts and identifying optimization opportunities.

## Technical Reality

Claude has no programmatic access to its own context window contents or token usage (GitHub issues #36678, #34879). This skill therefore:

- Reads source files from disk that Claude Code assembles into context
- Estimates token counts using character‑count heuristics (~4 chars per token) — **clearly labeled as estimates, not measurements**
- Accounts for the observer effect (the skill’s own SKILL.md content inflates the measurement)
- Cannot reconstruct injected content such as system reminders, deferred tool lists, or MCP server instruction text

## What It Reconstructs

The skill reads and analyzes these source files:

| Source | Path(s) | Notes |
|--------|---------|-------|
| **Global CLAUDE.md** | `~/.claude/CLAUDE.md` | Estimated tokens, @‑includes traced transitively |
| **Project CLAUDE.md** | `.claude/CLAUDE.md`, `./CLAUDE.md` | If present, estimated tokens, @‑includes traced |
| **@‑includes** | Any `@filename` references in CLAUDE.md files | Full inclusion tree, cumulative size reported |
| **MCP server configs** | `settings.json`, `.mcp.json` | Lists configured servers; cannot read injected instruction text. MCP servers add 50‑143K tokens at startup (community‑reported estimates) — often the largest context cost. |
| **Memory index** | `MEMORY.md` | Read if it exists (may not exist in all setups) |
| **Git status** | (implicit) | Minor fixed overhead, noted but not analyzed |

## Analysis Dimensions

For each reconstructable source:

1. **Estimated token count** – character‑based heuristic (`tokens ≈ characters ÷ 4`)
2. **Staleness** – references to files/paths/tools that don’t exist on disk
3. **Redundancy** – content repeated across multiple sources (e.g., same instructions in global and project CLAUDE.md)
4. **Relevance to current project** – global instructions that reference project‑specific paths/tools (advisory; subjective)
5. **Actionability** – instructions referencing tools, workflows, or files that don’t exist

## Output

A structured report with:

- **Inventory table**: source, estimated tokens, staleness/redundancy flags
- **Total estimated context overhead** before the first user message
- **MCP server count** and estimated tool overhead (flagged as major cost if >3 servers)
- **Ranked list of improvement suggestions** (largest token savings first)
- **Specific items to move, remove, consolidate, or make project‑specific**

## What It Does NOT Do

- **Does not modify any files** – analysis only; user decides what to act on
- **Does not measure actual token usage** – no API for this
- **Does not read MCP server instruction text** – injected by Claude Code, not accessible from disk
- **Does not inspect plugin caches or marketplace content**

## Implementation Checklist

When this skill is invoked, work through these checks systematically. Use the same file‑existence checking, @‑include parsing, and token‑estimation patterns as the config‑cleaner agent.

### Robustness & Error Handling

Before starting analysis, verify the environment can support inspection:

1. **Check for `~/.claude/` directory:**
   ```bash
   if [ ! -d ~/.claude ]; then
     echo "Error: ~/.claude directory not found. Claude Code may not be configured."
     exit 1
   fi
   ```

2. **Handle missing global CLAUDE.md gracefully:**
   ```bash
   if [ ! -f ~/.claude/CLAUDE.md ]; then
     echo "Note: Global CLAUDE.md not found. Starting with empty baseline."
     # Create empty temporary file for consistency
     touch /tmp/empty_claude.md
     GLOBAL_FILE="/tmp/empty_claude.md"
   else
     GLOBAL_FILE="~/.claude/CLAUDE.md"
   fi
   ```

3. **Validate JSON before parsing:**
   ```bash
   # Check if settings.json exists and is valid JSON
   if [ -f ~/.claude/settings.json ]; then
     if ! jq empty ~/.claude/settings.json 2>/dev/null; then
       echo "Warning: settings.json contains invalid JSON. MCP server count may be inaccurate."
     fi
   fi
   ```

4. **Fallback when git not available:**
   - If `git status` fails, note "Git status unavailable" and use fixed 100 token estimate.

### Quick Mode (Simple Token Count)

For a fast assessment that estimates total context overhead without deep analysis:

1. **Global CLAUDE.md**: Count characters, estimate tokens (`chars ÷ 4`).
2. **Project CLAUDE.md**: If present, count characters, add to total.
3. **MCP servers**: Count configured servers, multiply by ~75K (midpoint of 50‑143K range; see `references/mcp-costs.md`).
4. **MEMORY.md**: If present, add character‑based estimate.
5. **Sum and report**: Total estimated tokens with disclaimer.

Skip staleness, redundancy, relevance, and actionability checks.

**When to use Quick Mode:** For simple "how many tokens" questions or quick context overhead estimates. Use the full checklist for optimization audits.

### 1. File Reference Integrity

**Global CLAUDE.md:**
- **Check existence first:** Use robustness pattern above. If file missing, report "No global CLAUDE.md found" and skip to project analysis.
- If present, read `~/.claude/CLAUDE.md` with `cat`.
- Count characters: `cat ~/.claude/CLAUDE.md | wc -c`.
- Parse `@filename` references: `grep -E '@[a-zA-Z0-9_.-]+\.md' ~/.claude/CLAUDE.md`.
- For each matched `@filename`:
  - Resolve path: same directory as the source file.
  - Check existence: `test -f "$resolved_path"`.
  - If exists, read it recursively (may have its own @‑includes).
  - Build inclusion tree showing cumulative character count.
- Report: total characters, estimated tokens, @‑include tree.

**Project CLAUDE.md (if present):**
- Check `.claude/CLAUDE.md` and `./CLAUDE.md`.
- Perform same analysis as global.
- Note: project files override/append to global instructions.

### 2. MCP Server Inventory

**Read settings:**
- **Check existence:** First verify `~/.claude/settings.json` exists. If not, check `~/.claude/.mcp.json`. If neither exists, report "No MCP server configuration found" and skip MCP analysis.
- **Preferred (jq):** `cat ~/.claude/settings.json | jq '.mcpServers'` (if jq available). If JSON is malformed, note "Cannot parse settings.json".
- **Python alternative:** `python -c "import json, sys; data=json.load(open(sys.argv[1])); print(json.dumps(data.get('mcpServers', {})))" ~/.claude/settings.json`. Handles JSON errors via try/except.
- **Node.js alternative:** `node -e "const fs=require('fs'); console.log(JSON.stringify(JSON.parse(fs.readFileSync(process.argv[1])).mcpServers || {}))" ~/.claude/settings.json`. Handles JSON parse errors.
- **Fallback (grep - simple count):** If no JSON parser available, use `grep -c '\"command\"' ~/.claude/settings.json` to estimate server count (less accurate).
- Also check `~/.claude/.mcp.json` (standalone config) with same methods.
- For each server entry:
  - Extract `command` field (binary name).
  - Check PATH: `which <binary>`.
  - Note server name and binary status (found/missing).
- Count total servers. Flag if >3: "High MCP overhead likely".

**MCP token overhead note:**
- Each MCP server adds ~50‑143K tokens at startup (community‑reported estimates; see `references/mcp-costs.md` for breakdown).
- Cannot read injected instruction text (Claude Code internal).

### 3. Memory Index Check

**Check for MEMORY.md:**
- `test -f ~/.claude/MEMORY.md` and `test -f ./MEMORY.md`.
- If present, count characters, estimate tokens.
- Note if large (>1000 lines).

### 4. Git Status Overhead

**Fixed estimate with fallback:**
- Git status adds ~100 tokens (fixed overhead).
- **If git not available:** Note "Git not available, using estimated 100 token overhead".
- Note but don't analyze further.

### 5. Staleness Detection

**For each file path referenced:**
- In CLAUDE.md: explicit paths like `~/.claude/conventions/...` or `./.claude/...`.
- In @‑includes: the included files themselves.
- Check existence with `test -f`.
- Report missing files as staleness issues.

### 6. Redundancy Detection

**Compare global vs. project CLAUDE.md using exact‑string matching:**
1. **Create clean copies:** Strip comments (lines starting with `#`) and blank lines from both files.
   ```bash
   grep -v '^#' ~/.claude/CLAUDE.md | grep -v '^$' > /tmp/global_clean.txt
   grep -v '^#' .claude/CLAUDE.md | grep -v '^$' > /tmp/project_clean.txt
   ```
2. **Exact line matching (identical lines):**
   ```bash
   comm -12 <(sort /tmp/global_clean.txt) <(sort /tmp/project_clean.txt) > /tmp/identical_lines.txt
   ```
3. **Exact phrase matching (common instructions):** Search for these exact phrases in both files:
   ```bash
   # Check for common duplicate instructions (case‑sensitive exact match)
   for phrase in "use bd for task tracking" "never use TodoWrite" "always commit with conventional commits"; do
     if grep -F "$phrase" /tmp/global_clean.txt && grep -F "$phrase" /tmp/project_clean.txt; then
       echo "Duplicate phrase found: $phrase"
     fi
   done
   ```
4. **Scope:** Check both top‑level instructions and @‑include content (transitively).
5. **Label as "Review — needs user judgment"** and report duplicate token count.

### 7. Relevance Assessment

**Scan global CLAUDE.md for project‑specific references:**
- Paths containing `./`, `src/`, `lib/`, project‑relative patterns.
- Tool references that only make sense in a specific project context.
- Flag as candidates to move to project CLAUDE.md.

### 8. Actionability Check

**Identify instructions referencing missing tools/workflows:**
- Tools not in Claude Code's standard toolset (check current documentation for available tools).
- Workflows referencing files that don't exist.
- Commands that would fail if executed.

### 9. Token Estimation

**For each scanned file:**
- Character count: `wc -c` or equivalent.
- Estimated tokens: `characters ÷ 4`.
- **Always label as estimates**, not measurements.
- See `references/token-estimation.md` for accuracy details and alternative methods.
- Sum per category: global, project, @‑includes, MEMORY.md.

**Observer effect note:**
- The inspector's own SKILL.md adds ~N tokens to the measurement.
- Mention in report.

### 10. Report Assembly

Follow the **Report Format** section below to produce a structured markdown report.

## Report Format

Produce a structured markdown report following this template. Include concrete numbers, specific file paths, and actionable suggestions.

```
# Context Window Inspector Report

## Summary
- **Total estimated context overhead:** ~12,850 tokens
- **MCP servers configured:** 4 (⚠️ high overhead — each adds ~50‑143K tokens at startup, community‑reported estimates)
- **Total findings:** 5 (Remove: 1, Review: 3, Consolidate: 1, Optimize: 1)
- **Observer effect:** This inspector's SKILL.md adds ~400 tokens to the measurement

## Inventory Table

| Source | Path | Est. Tokens | Flags |
|--------|------|-------------|-------|
| Global CLAUDE.md | `~/.claude/CLAUDE.md` | ~2,400 | Includes `@best-practices.md` (800 tokens), `@workflow-conventions.md` (600 tokens) |
| Project CLAUDE.md | `.claude/CLAUDE.md` | ~1,200 | No @‑includes |
| @‑includes (cumulative) | `@best-practices.md`, `@workflow-conventions.md` | ~1,400 | Tree: CLAUDE.md → best‑practices.md → workflow‑conventions.md |
| MCP servers (4) | `settings.json` | ~200K–572K total | `web-reader` (binary found), `pdf-tools` (binary found), `sequencing` (binary missing), `github-api` (binary found) |
| MEMORY.md | `~/.claude/MEMORY.md` | ~750 | 42 entries, last updated 2026‑02‑10 |
| Git status | (implicit) | ~100 | Fixed overhead |

*Note: MCP server token range is per‑server startup cost (50‑143K tokens, community‑reported estimates). Cannot read injected instruction text.*

## Findings

### Remove (Clearly dead or broken)

**1. Broken @‑include in global CLAUDE.md**
- **Location:** `~/.claude/CLAUDE.md` line 18
- **Issue:** `@deprecated-conventions.md` does not exist on disk
- **Token waste:** ~300 tokens (file would add ~300 tokens if present)
- **Action:** Remove the `@deprecated-conventions.md` line

### Review (Needs user judgment)

**1. Missing MCP server binary**
- **Location:** `settings.json` → `mcpServers.sequencing`
- **Issue:** `sequencing-server` not found on PATH (`which` returns empty) — may cause silent timeout errors
- **Token waste:** ~50‑143K tokens at startup (community‑reported estimate) for a potentially non‑functional server
- **Action:** Install `sequencing-server` or remove the config entry

**2. Project‑specific paths in global instructions**
- **Location:** `~/.claude/CLAUDE.md` lines 45‑48
- **Issue:** References `./src/lib/utils.js` — a project‑relative path that doesn't apply globally
- **Token waste:** ~80 tokens (irrelevant to most sessions)
- **Action:** Move these lines to project‑specific CLAUDE.md files where relevant

**3. Large MEMORY.md**
- **Location:** `~/.claude/MEMORY.md`
- **Issue:** 750 tokens (42 entries). Some entries >6 months old.
- **Action:** Review and archive stale entries; consider moving project‑specific memories to project MEMORY.md

### Consolidate (Duplicate or redundant content)

**1. Duplicate task‑tracking instruction**
- **Locations:** `~/.claude/CLAUDE.md` line 3, `.claude/CLAUDE.md` line 5
- **Issue:** Both state "Use `bd` for task tracking — never TodoWrite" with identical wording
- **Token waste:** ~120 tokens (duplicate)
- **Action:** Keep in project CLAUDE.md only; remove from global CLAUDE.md

### Optimize (Performance improvements)

**1. High MCP server count**
- **Count:** 4 servers configured
- **Overhead:** 200K–572K tokens at startup
- **Suggestion:** Evaluate whether all 4 servers are needed simultaneously; disable unused ones via `settings.local.json`

## Improvement Suggestions (by token impact)

### High Impact (saves 50‑143K+ tokens, community‑reported estimates)
1. **Fix or remove missing MCP server** — `sequencing` server binary not found
2. **Remove broken @‑include** — `@deprecated-conventions.md`

### Medium Impact (saves 200‑500 tokens)
1. **Consolidate duplicate instructions** — task tracking in global vs. project CLAUDE.md
2. **Move project‑specific instructions** — global CLAUDE.md references `./src/lib/utils.js`

### Low Impact (saves <200 tokens)
1. **Review MEMORY.md entries** — archive stale ones
2. **Consider MCP server consolidation** — do you need all 4 servers?

## Notes

- **Token estimates** are based on character‑count heuristics (~4 characters per token). Not actual measurements.
- **Observer effect:** This inspector's SKILL.md adds ~400 tokens to the context when invoked.
- **MCP server overhead** is the largest contributor to context bloat (50‑143K tokens per server at startup, based on community‑reported estimates).
- **Some content cannot be reconstructed:** system reminders, deferred tool lists, and injected MCP server instruction text are not readable from disk.
```

## Example Output

The **Report Format** section above includes a complete example report with realistic numbers, concrete findings, and actionable suggestions. Use it as a template when generating reports.

## Integration with Other Skills/Agents

See `references/integration.md` for detailed integration patterns with config‑cleaner, self‑audit, Scout, git‑context‑recovery, reduce‑hallucinations, and round skills/agents.

## Prioritization Decision Guide

Use this table to decide which findings to address first based on impact and effort:

| Finding Type | Severity | Token Impact | Effort | When to Act | Decision Rule |
|-------------|----------|--------------|--------|-------------|---------------|
| **Missing MCP binary** | Review | 50‑143K tokens (est.) | Medium | Next session | If server unused, remove config; if needed, install binary |
| **Broken @‑include** | Remove | 100‑1000 tokens | Low | Immediate | Always remove — references non‑existent file |
| **Duplicate instructions** | Consolidate | 50‑500 tokens | Low | When editing file | Keep one copy, remove duplicates |
| **Project‑specific paths in global** | Review | 50‑200 tokens | Medium | When reorganizing | Move to project‑specific CLAUDE.md |
| **Large MEMORY.md** | Review | 100‑1000 tokens | High | Periodic cleanup | Archive >6‑month old entries, move project‑specific |
| **High MCP server count** | Optimize | 50‑143K per server (est.) | High | Planning session | Disable unused servers, consolidate tools |

### Decision Flow

1. **Start with Remove items** — broken references provide zero value, easy fixes
2. **Then Review high‑impact** — missing MCP binaries waste most tokens
3. **Address Consolidate items** — duplicates during related file edits
4. **Schedule Optimize items** — server consolidation requires planning
5. **Periodic Review** — revisit MEMORY.md and server count quarterly

## Best Practices

- Run this inspection when you suspect configuration bloat or before adding new MCP servers.
- Treat token estimates as directional, not absolute.
- Address staleness and redundancy first — they are clear wins.
- Remember that MCP servers are the largest single source of context overhead.

## Testing & Edge Cases

This skill includes a comprehensive test suite (`test/` directory) that validates:

- **Malformed JSON handling**: Test cases with invalid JSON to ensure graceful degradation
- **Missing files**: References to non‑existent `@‑include` files are detected as staleness
- **Circular includes**: Detection and reporting of circular reference chains
- **Large files**: Handling of files >10K lines with performance considerations
- **Missing directories**: Graceful handling when `~/.claude/` doesn't exist

Run the reference implementation with `test/run‑test.sh` to verify the inspection logic works correctly in your environment.

---

**This skill enables data‑driven optimization of Claude Code configuration through visibility, not guesswork.**