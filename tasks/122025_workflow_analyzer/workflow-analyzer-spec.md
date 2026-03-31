# Workflow Analyzer Agent - Specification

## Problem Statement

After investing in Claude Code configuration (plugins, agents, skills, MCP servers), there's no visibility into:
- Which installed capabilities are actually being used
- What workflow patterns waste tokens (manual work that could be automated)
- Which tools/agents would improve efficiency but remain unused
- How configuration changes impact workflow over time

**Discovered gap:** Existing tools (Claude Viewer, History MCP) provide token tracking and basic analytics, but none offer **proactive optimization suggestions** or **capability utilization analysis**.

---

## Requirements

### Functional Requirements

**FR1: Capability Inventory**
- Scan all available tools: commands, agents, skills, MCP servers
- Distinguish between globally installed vs project-specific
- Track plugin-provided capabilities separately
- Record installation date/version if available

**FR2: Usage Pattern Analysis**
- Parse history.jsonl for actual tool/agent/command usage
- Calculate usage frequency (daily/weekly/monthly)
- Identify most/least used capabilities
- Segment by project if applicable

**FR3: Inefficiency Detection**
- Pattern matching for workflow anti-patterns:
  - Multiple manual file reads → suggest Explore agent
  - Repeated grep/search → suggest creating custom command
  - Frequent git operations → suggest git-advanced-workflows skill
  - Sequential tool calls → suggest creating compound skill
- Token waste identification (high-token operations repeated unnecessarily)

**FR4: Underutilized Capability Suggestions**
- Compare "available" vs "used" capabilities
- Recommend specific tools for observed workflow patterns
- Explain WHY each suggestion would help (concrete benefit)
- Prioritize by potential impact

**FR5: Reporting**
- Generate markdown report with clear sections
- Provide actionable recommendations (not just data)
- Include before/after examples where applicable
- Support filtering by time period (last week/month/all time)

### Non-Functional Requirements

**NFR1: Zero Monitoring Overhead**
- Post-hoc analysis only (no runtime hooks)
- Reads existing data (history.jsonl, settings files)
- Manual invocation (user decides when to run)

**NFR2: Pull-Based Architecture**
- No background processes
- No continuous collection
- No separate database/storage (analyze from source files)

**NFR3: Lightweight**
- Single agent file (no external dependencies beyond standard tools)
- Minimal token consumption during analysis
- Fast execution (<30 seconds for typical analysis)

**NFR4: Privacy**
- All analysis happens locally
- No data sent to external services
- Respects project boundaries (no cross-project recommendations without consent)

---

## Agent Design

### Agent Identity

**Name:** Workflow Analyzer
**Codename:** `workflow-analyzer`
**Role:** Claude Code efficiency consultant
**Model:** Sonnet (requires reasoning for pattern detection)

### Agent Capabilities

The agent will have access to these tools:
- **Read** - Parse history.jsonl, settings.json, command/agent files
- **Glob** - Discover available capabilities across directories
- **Grep** - Search history for usage patterns
- **Bash** - Execute jq for JSON parsing, wc for counting, date calculations
- **TodoWrite** - Structure analysis tasks for complex reports

### Invocation Patterns

```bash
# Basic usage
cc chat -a workflow-analyzer "Analyze my last 7 days"

# Specific focus
cc chat -a workflow-analyzer "What agents am I not using?"
cc chat -a workflow-analyzer "Find workflow inefficiencies in project X"
cc chat -a workflow-analyzer "Compare last month vs this month"

# Deep dive
cc chat -a workflow-analyzer "Full audit with recommendations"
```

### Output Structure

**Section 1: Usage Summary**
- Time period analyzed
- Total sessions, total tokens
- Top 5 most-used tools/agents/commands
- Usage frequency distribution

**Section 2: Capability Inventory**
- Table: Capability | Type | Installed | Last Used | Usage Count
- Highlight: Never used vs frequently used
- Filter: Show only unused capabilities with explanation

**Section 3: Workflow Inefficiencies**
- Pattern-based findings:
  - "You read 47 files manually across 12 sessions → Use Explore agent (saves ~15k tokens)"
  - "You grep'd for 'API endpoint' 8 times → Create /find-api command"
  - "You invoke commit workflow in 3 separate steps → Use commit-commands:commit-push-pr skill"
- Token impact for each inefficiency

**Section 4: Underutilized Capabilities**
- Recommendations with justification:
  - "Enable sequential-thinking MCP → Your sessions show complex multi-step planning (5+ steps)"
  - "Use git-advanced-workflows skill → You manually cherry-pick commits 4 times last week"
  - "Install claude-viewer MCP → You asked 'where are my tokens going' 3 times"
- Installation instructions for recommended tools

**Section 5: Action Items**
- Prioritized list of 3-5 high-impact changes
- Estimated effort (1 min / 5 min / 30 min)
- Expected benefit (token savings, time savings, quality improvement)

---

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Workflow Analyzer Agent                   │
└─────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
            ▼               ▼               ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │  Inventory   │ │    Usage     │ │   Pattern    │
    │   Scanner    │ │   Analyzer   │ │  Detector    │
    └──────────────┘ └──────────────┘ └──────────────┘
            │               │               │
            │               │               │
            ▼               ▼               ▼
    ┌──────────────────────────────────────────────┐
    │            Recommendation Engine              │
    └──────────────────────────────────────────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │  Report Generator│
                  └──────────────────┘
```

### Data Sources

**Input Files:**
```
~/.claude/
├── history.jsonl              # Session history (primary data source)
├── settings.json              # Enabled plugins, MCP servers
├── commands/                  # Available slash commands
├── agents/                    # Available agents
├── skills/                    # Available skills
└── plugins/
    └── */
        ├── commands/          # Plugin-provided commands
        ├── agents/            # Plugin-provided agents
        └── skills/            # Plugin-provided skills

~/.claude/projects/*/
└── *.jsonl                    # Project-specific history
```

**Data Extraction Strategy:**

1. **Inventory Scanner:**
   ```bash
   # Commands
   ls ~/.claude/commands/*.md | wc -l

   # Agents
   ls ~/.claude/agents/*.md | wc -l

   # Skills
   find ~/.claude/plugins -name "SKILL.md" -type f

   # MCP Servers
   cat ~/.claude/settings.json | jq -r '.mcpServers | keys[]'
   ```

2. **Usage Analyzer:**
   ```bash
   # Parse history.jsonl for tool usage
   cat ~/.claude/history.jsonl | \
     jq -r 'select(.type == "tool_use") | .tool_name' | \
     sort | uniq -c | sort -rn

   # Agent invocations
   cat ~/.claude/history.jsonl | \
     jq -r 'select(.content | contains("-a ")) | .content' | \
     grep -oP '(?<=-a )[^ ]+' | sort | uniq -c

   # Command invocations
   cat ~/.claude/history.jsonl | \
     jq -r 'select(.content | startswith("/")) | .content' | \
     cut -d' ' -f1 | sort | uniq -c
   ```

3. **Pattern Detector:**
   - Scan for sequences like: Read → Read → Read → Read (suggest Explore)
   - Scan for repeated Grep patterns (suggest custom command)
   - Scan for manual git workflows (suggest git skills)
   - Scan for complex reasoning chains (suggest sequential-thinking MCP)

### Analysis Pipeline

**Phase 1: Data Collection (5 seconds)**
1. Read time period from user input (default: last 7 days)
2. Filter history.jsonl to time window
3. Scan available capabilities (commands/agents/skills/MCPs)
4. Build two datasets: "Available" and "Used"

**Phase 2: Usage Analysis (10 seconds)**
1. Calculate usage frequency for each capability
2. Identify "never used" vs "frequently used" (percentile distribution)
3. Segment by project if multi-project usage detected
4. Calculate token consumption per capability type

**Phase 3: Pattern Detection (10 seconds)**
1. Apply heuristics for common anti-patterns:
   - `Read` tool used >10 times in session → Check if Explore agent used
   - `Grep` with same pattern >3 times → Suggest command
   - Manual file reads + edits in sequence → Suggest multi-edit tools
   - Complex reasoning visible in prompts → Check sequential-thinking MCP
2. Score inefficiencies by token impact (high/medium/low)

**Phase 4: Recommendation Generation (5 seconds)**
1. Cross-reference unused capabilities with detected patterns
2. Generate specific recommendations with justification
3. Estimate effort and impact for each recommendation
4. Prioritize by ROI (impact / effort ratio)

**Phase 5: Report Generation (5 seconds)**
1. Format markdown report with sections
2. Include usage charts (text-based tables)
3. Provide actionable next steps
4. Optionally save report to file

**Total Time:** ~35 seconds

### Algorithm: Inefficiency Detection

**Heuristic Rules:**

```javascript
// Pseudocode for pattern detection

function detectInefficiencies(historyData) {
  const inefficiencies = [];

  // Rule 1: Excessive manual file reads
  const fileReads = historyData.filter(h => h.tool_name === 'Read');
  if (fileReads.length > 10 && !usedAgent('Explore')) {
    inefficiencies.push({
      type: 'manual_exploration',
      severity: 'high',
      message: `You read ${fileReads.length} files manually`,
      suggestion: 'Use Explore agent for codebase discovery',
      tokenImpact: fileReads.length * 500 // estimate
    });
  }

  // Rule 2: Repeated search patterns
  const greps = historyData.filter(h => h.tool_name === 'Grep');
  const patterns = groupBy(greps, g => g.parameters.pattern);
  for (const [pattern, uses] of Object.entries(patterns)) {
    if (uses.length >= 3) {
      inefficiencies.push({
        type: 'repeated_search',
        severity: 'medium',
        message: `You searched for "${pattern}" ${uses.length} times`,
        suggestion: `Create /find-${slugify(pattern)} command`,
        tokenImpact: uses.length * 200
      });
    }
  }

  // Rule 3: Manual git workflows
  const gitBash = historyData.filter(h =>
    h.tool_name === 'Bash' && h.parameters.command.startsWith('git ')
  );
  if (gitBash.length > 5 && !usedSkill('git-advanced-workflows')) {
    inefficiencies.push({
      type: 'manual_git',
      severity: 'medium',
      message: `You ran ${gitBash.length} git commands manually`,
      suggestion: 'Use git-advanced-workflows skill for common operations',
      tokenImpact: gitBash.length * 100
    });
  }

  // Rule 4: Complex reasoning without tools
  const longPrompts = historyData.filter(h =>
    h.type === 'user_message' && h.content.split(' ').length > 100
  );
  if (longPrompts.length > 3 && !usedMCP('sequential-thinking')) {
    inefficiencies.push({
      type: 'complex_reasoning',
      severity: 'low',
      message: 'Multiple complex prompts detected',
      suggestion: 'Enable sequential-thinking MCP for structured reasoning',
      tokenImpact: 'unknown'
    });
  }

  return inefficiencies.sort((a, b) =>
    severityScore(b.severity) - severityScore(a.severity)
  );
}
```

### Algorithm: Underutilized Capability Detection

```javascript
// Pseudocode for recommendation engine

function recommendCapabilities(available, used, patterns) {
  const recommendations = [];

  // Find never-used capabilities
  const unused = available.filter(cap => !used.includes(cap.name));

  // Match unused capabilities to observed patterns
  for (const capability of unused) {
    const match = matchPatternToCapability(patterns, capability);
    if (match.score > 0.7) {
      recommendations.push({
        capability: capability.name,
        type: capability.type,
        reason: match.reason,
        benefit: match.estimatedBenefit,
        effort: estimateInstallationEffort(capability),
        priority: calculatePriority(match.score, match.estimatedBenefit)
      });
    }
  }

  return recommendations.sort((a, b) => b.priority - a.priority);
}

function matchPatternToCapability(patterns, capability) {
  // Example matching logic
  if (capability.name === 'Explore' && patterns.manual_exploration) {
    return {
      score: 0.95,
      reason: 'You frequently read multiple files manually',
      estimatedBenefit: 'Save ~15k tokens per codebase exploration'
    };
  }

  if (capability.type === 'mcp' && capability.name === 'sequential-thinking') {
    const complexReasoningCount = patterns.complex_reasoning?.count || 0;
    if (complexReasoningCount > 2) {
      return {
        score: 0.8,
        reason: `${complexReasoningCount} complex multi-step prompts detected`,
        estimatedBenefit: 'Better structured reasoning, fewer retries'
      };
    }
  }

  // ... more matching rules

  return { score: 0, reason: null, estimatedBenefit: null };
}
```

---

## Implementation Options

### Option 1: Agent (Recommended)

**Pros:**
- Simplest to implement (single markdown file)
- User controls invocation (pull-based)
- Can evolve over time (edit agent instructions)
- No dependencies beyond standard tools

**Cons:**
- Not reusable across sessions without re-invocation
- Agent must re-parse data each time (no caching)

**File:** `~/.claude/agents/workflow-analyzer.md`

**Implementation effort:** 2-3 hours

---

### Option 2: MCP Server

**Pros:**
- Reusable tools across sessions
- Can cache inventory data
- More structured API
- Can be shared with community

**Cons:**
- More complex implementation (Node.js/Python server)
- Requires MCP protocol knowledge
- Installation overhead for users

**Implementation effort:** 6-8 hours

---

### Option 3: Skill

**Pros:**
- Lightweight (can be invoked via `/workflow-analysis`)
- Self-contained
- Easy to distribute

**Cons:**
- Skills are simpler than agents (less capability)
- May not have enough flexibility for complex analysis

**Implementation effort:** 1-2 hours

---

## Recommendation: Start with Agent

**Phase 1:** Build agent (this task)
**Phase 2:** Test for 2 weeks, gather feedback
**Phase 3:** If valuable, consider MCP server for persistence

---

## Example Output

```markdown
# Workflow Analysis Report
**Period:** 2025-12-13 to 2025-12-20 (7 days)
**Sessions:** 24
**Total tokens:** 487,392

---

## Usage Summary

### Most Used Tools
1. Read (147 invocations)
2. Grep (83 invocations)
3. Edit (56 invocations)
4. Bash (41 invocations)
5. Write (23 invocations)

### Most Used Agents
1. general-purpose (12 invocations)
2. Explore (3 invocations)
3. claude-code-guide (2 invocations)

### Most Used Commands
1. /commit (8 invocations)
2. /cluddha (4 invocations)

---

## Capability Inventory

### Never Used (Installed but unused)
- **Agent:** `feature-dev:code-reviewer` - Installed 3 months ago, 0 uses
- **Agent:** `python-development:fastapi-pro` - Installed 2 months ago, 0 uses
- **Skill:** `git-advanced-workflows` - Installed 1 month ago, 0 uses
- **MCP Server:** `sequential-thinking` - Installed 1 week ago, 0 uses

### Rarely Used (<1 use per week)
- **Agent:** `Explore` - 3 uses in 7 days (could use more)

---

## Workflow Inefficiencies

### HIGH: Excessive Manual File Reads
**Finding:** You used Read tool 147 times across 24 sessions (avg 6.1 per session).

**Pattern detected:** In 8 sessions, you read 10+ files sequentially to understand codebase structure.

**Recommendation:** Use Explore agent for codebase discovery instead of manual file reads.

**Impact:** Estimated savings of ~20k tokens per exploration session (160k tokens total)

**Example session:**
- Session #12 (2025-12-18): Read 23 files to understand authentication flow
- Could have been: `cc chat -a Explore "How does authentication work?"`

---

### MEDIUM: Repeated Git Operations
**Finding:** You ran git commands manually 27 times across 15 sessions.

**Common patterns:**
- `git add . && git commit -m "..."` (8 times)
- `git log --oneline` (6 times)
- `git diff` before commits (7 times)

**Recommendation:** Use `/commit` skill (already installed) OR enable `git-advanced-workflows` skill.

**Impact:** Save ~5 minutes per commit workflow, reduce prompt tokens by ~500 per operation.

---

### LOW: Complex Planning Without Sequential Thinking
**Finding:** 4 sessions included prompts >150 words describing multi-step plans.

**Recommendation:** Enable `sequential-thinking` MCP (already installed, never used).

**Impact:** Better structured reasoning, fewer clarification rounds.

---

## Underutilized Capabilities

### 1. Explore Agent (Installed, rarely used)
**Why you need it:** 8 sessions showed manual codebase exploration patterns.

**What it does:** Quickly explores codebases and answers architecture questions without manual file reads.

**How to use:** `cc chat -a Explore "quick" "How does error handling work?"`

**Expected benefit:** 20k token savings per exploration session.

---

### 2. git-advanced-workflows Skill (Installed, never used)
**Why you need it:** 27 manual git commands detected, many repetitive.

**What it does:** Provides skills for rebasing, cherry-picking, bisect, worktrees.

**How to use:** Check skill documentation in `~/.claude/plugins/.../skills/git-advanced-workflows/`

**Expected benefit:** Faster git workflows, fewer manual commands.

---

### 3. sequential-thinking MCP (Installed, never used)
**Why you need it:** 4 complex planning sessions detected.

**What it does:** Structures complex reasoning into step-by-step thinking.

**How to enable:** Already in settings.json, just invoke when needed.

**Expected benefit:** More thorough analysis, fewer missed edge cases.

---

## Action Items

### Priority 1: Use Explore for codebase discovery (1 min effort, high impact)
Next time you need to understand codebase structure, run:
`cc chat -a Explore "medium" "Explain the architecture"`

### Priority 2: Enable git-advanced-workflows skill (5 min effort, medium impact)
Read skill docs, replace manual git workflows with skill invocations.

### Priority 3: Try sequential-thinking MCP (1 min effort, low-medium impact)
On next complex planning task, let MCP structure your reasoning.

### Priority 4: Disable unused agents (2 min effort, cleanup)
Consider removing `python-development:fastapi-pro` if you don't use Python/FastAPI.

### Priority 5: Review installed plugins (30 min effort, audit)
Run through `~/.claude/settings.json` plugins list, disable what you don't use.

---

## Next Steps

1. **Immediate:** Try Explore agent on next codebase question
2. **This week:** Read git-advanced-workflows documentation
3. **This month:** Re-run this analysis and compare usage patterns

**To re-run this analysis:** `cc chat -a workflow-analyzer "Analyze last 7 days"`
```

---

## Success Metrics

After 1 month of using this agent:

**Visibility:**
- ✅ Know exactly which tools/agents/skills are used vs available
- ✅ Identify workflow inefficiencies based on real data

**Optimization:**
- 🎯 10-20% reduction in manual file reads (use Explore more)
- 🎯 Faster git workflows (use skills vs manual commands)
- 🎯 Higher utilization of installed capabilities (>50% usage rate)

**Workflow Improvement:**
- 🎯 Run analysis weekly to track progress
- 🎯 Adjust configuration based on recommendations
- 🎯 Measure token savings month-over-month

---

## Next Steps (This Design Task)

1. ✅ Complete this specification
2. Design agent markdown file structure
3. Write deployment/installation guide
4. Create example agent file
5. Test with real history.jsonl data
6. Document limitations and future enhancements
