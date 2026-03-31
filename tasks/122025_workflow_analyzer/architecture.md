# Workflow Analyzer - Architecture Design

## Architecture Overview

The Workflow Analyzer is a **stateless, pull-based analysis agent** that reads existing Claude Code data files and generates insights about tool usage, workflow patterns, and optimization opportunities.

**Core Principle:** Zero monitoring overhead - analyze after the fact, not during execution.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INVOCATION                          │
│  cc chat -a workflow-analyzer "Analyze my last 7 days"          │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      WORKFLOW ANALYZER AGENT                     │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              INPUT PARSING & VALIDATION                     │ │
│  │  • Parse time period (last 7 days / last month / etc)      │ │
│  │  • Validate data sources exist (~/.claude/history.jsonl)   │ │
│  │  • Determine scope (global vs project-specific)            │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                │                                 │
│                                ▼                                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  DATA COLLECTION LAYER                      │ │
│  │                                                             │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐ │ │
│  │  │  Inventory   │  │   History    │  │    Settings      │ │ │
│  │  │   Scanner    │  │    Parser    │  │    Reader        │ │ │
│  │  └──────────────┘  └──────────────┘  └──────────────────┘ │ │
│  │         │                  │                   │           │ │
│  └─────────┼──────────────────┼───────────────────┼───────────┘ │
│            │                  │                   │              │
│            ▼                  ▼                   ▼              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │               DATA AGGREGATION & NORMALIZATION             │ │
│  │  • Available: {commands: [], agents: [], skills: [], ...} │ │
│  │  • Used: {tool_calls: [], agent_calls: [], cmd_calls: []} │ │
│  │  • Metadata: {sessions: N, tokens: N, projects: [...]}    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                │                                 │
│                                ▼                                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    ANALYSIS ENGINES                         │ │
│  │                                                             │ │
│  │  ┌──────────────────────┐  ┌──────────────────────────┐   │ │
│  │  │  Usage Analyzer      │  │  Pattern Detector        │   │ │
│  │  │  • Frequency calc    │  │  • Inefficiency rules    │   │ │
│  │  │  • Percentile dist   │  │  • Anti-pattern matching │   │ │
│  │  │  • Token attribution │  │  • Token waste scoring   │   │ │
│  │  └──────────────────────┘  └──────────────────────────┘   │ │
│  │             │                          │                    │ │
│  │             └────────┬─────────────────┘                    │ │
│  │                      ▼                                      │ │
│  │  ┌───────────────────────────────────────────────────────┐ │ │
│  │  │         Recommendation Engine                         │ │ │
│  │  │  • Match patterns to unused capabilities             │ │ │
│  │  │  • Score recommendations by ROI                      │ │ │
│  │  │  • Prioritize by impact                              │ │ │
│  │  └───────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                │                                 │
│                                ▼                                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    REPORT GENERATOR                         │ │
│  │  • Format markdown sections                                │ │
│  │  • Create usage tables                                     │ │
│  │  • Generate actionable recommendations                     │ │
│  │  • Include examples and estimates                          │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                │                                 │
└────────────────────────────────┼─────────────────────────────────┘
                                 ▼
                    ┌────────────────────────┐
                    │   MARKDOWN REPORT      │
                    │   (to user terminal)   │
                    └────────────────────────┘
```

---

## Component Details

### 1. Data Collection Layer

#### Inventory Scanner

**Responsibility:** Discover all available capabilities

**Data Sources:**
```
~/.claude/
├── commands/*.md          → Slash commands
├── agents/*.md            → Available agents
├── skills/*.md            → Global skills (rare)
└── plugins/*/
    ├── commands/*.md      → Plugin commands
    ├── agents/*.md        → Plugin agents
    └── skills/SKILL.md    → Plugin skills

settings.json → mcpServers → MCP server list
```

**Tools Used:**
- `Glob` - Find all .md files in directories
- `Read` - Parse command/agent/skill metadata (YAML frontmatter)
- `Bash` + `jq` - Extract MCP server names from settings.json

**Output Schema:**
```json
{
  "commands": [
    {"name": "commit", "path": "~/.claude/commands/commit.md", "source": "user"},
    {"name": "cluddha", "path": ".claude/commands/cluddha.md", "source": "project"}
  ],
  "agents": [
    {"name": "Explore", "model": "sonnet", "source": "builtin"},
    {"name": "scout", "model": "sonnet", "source": "user"}
  ],
  "skills": [
    {"name": "git-advanced-workflows", "plugin": "developer-essentials", "source": "plugin"}
  ],
  "mcpServers": [
    {"name": "filesystem", "source": "builtin"},
    {"name": "sequential-thinking", "source": "user"}
  ]
}
```

#### History Parser

**Responsibility:** Extract usage data from history.jsonl

**Data Source:**
```
~/.claude/history.jsonl           → Global history
~/.claude/projects/*/*.jsonl      → Project-specific history
```

**Parsing Logic:**
```javascript
// Filter by time period
const startDate = parseTimeWindow(userInput); // "last 7 days" → timestamp
const relevantSessions = history.filter(entry =>
  entry.timestamp >= startDate
);

// Extract tool usage
const toolCalls = relevantSessions.filter(e => e.type === 'tool_use');

// Extract agent invocations (from user prompts)
const agentCalls = relevantSessions.filter(e =>
  e.role === 'user' && e.content.match(/-a ([^ ]+)/)
);

// Extract command invocations
const cmdCalls = relevantSessions.filter(e =>
  e.role === 'user' && e.content.startsWith('/')
);

// Extract token usage
const tokens = relevantSessions
  .filter(e => e.usage)
  .reduce((sum, e) => sum + e.usage.total_tokens, 0);
```

**Tools Used:**
- `Read` - Load history.jsonl
- `Bash` + `jq` - Parse JSONL, filter by date, extract fields
- `Grep` - Search for specific patterns (agent names, commands)

**Output Schema:**
```json
{
  "sessions": 24,
  "tokens": {
    "input": 312451,
    "output": 174941,
    "cache_creation": 0,
    "cache_read": 0,
    "total": 487392
  },
  "toolCalls": [
    {"tool": "Read", "count": 147, "sessions": 18},
    {"tool": "Grep", "count": 83, "sessions": 14},
    {"tool": "Edit", "count": 56, "sessions": 11}
  ],
  "agentCalls": [
    {"agent": "general-purpose", "count": 12},
    {"agent": "Explore", "count": 3},
    {"agent": "claude-code-guide", "count": 2}
  ],
  "commandCalls": [
    {"command": "/commit", "count": 8},
    {"command": "/cluddha", "count": 4}
  ]
}
```

#### Settings Reader

**Responsibility:** Understand current configuration

**Data Source:**
```
~/.claude/settings.json           → Global settings
~/.claude/settings.local.json     → Local overrides
.claude/settings.json             → Project settings
```

**Extract:**
- Enabled plugins
- Enabled MCP servers
- Custom configuration (if relevant to analysis)

**Tools Used:**
- `Read` - Load settings files
- `Bash` + `jq` - Parse JSON

---

### 2. Analysis Engines

#### Usage Analyzer

**Responsibility:** Calculate usage statistics

**Algorithms:**

1. **Frequency Distribution:**
   ```python
   # Calculate usage rate for each capability
   for capability in available:
       usage_count = count_in_history(capability.name)
       usage_rate = usage_count / total_sessions
       capability.frequency = categorize(usage_rate)
       # Categories: frequent (>50%), occasional (10-50%),
       #            rare (<10%), never (0%)
   ```

2. **Token Attribution:**
   ```python
   # Estimate token consumption by tool type
   # (Rough heuristic based on typical usage)
   token_estimates = {
       'Read': 500,        # per invocation
       'Grep': 300,
       'Edit': 400,
       'Bash': 200,
       'Write': 600,
       'Task': 5000        # agent spawns
   }

   for tool in tool_calls:
       estimated_tokens = tool.count * token_estimates.get(tool.name, 300)
       tool.token_impact = estimated_tokens
   ```

3. **Percentile Analysis:**
   ```python
   # Identify outliers (heavily used vs never used)
   usage_counts = [c.count for c in capabilities]
   p90 = percentile(usage_counts, 90)  # Top 10%
   p10 = percentile(usage_counts, 10)  # Bottom 10%

   top_capabilities = [c for c in capabilities if c.count >= p90]
   underused_capabilities = [c for c in capabilities if c.count <= p10]
   ```

**Output:**
- Ranked list of capabilities by usage
- Token impact estimates
- Usage categories (frequent/occasional/rare/never)

#### Pattern Detector

**Responsibility:** Identify workflow inefficiencies

**Detection Rules:**

```python
# Rule-based pattern matching

def detect_inefficiencies(history, tool_calls):
    inefficiencies = []

    # Pattern 1: Manual codebase exploration
    read_count = tool_calls.get('Read', 0)
    explore_count = agent_calls.get('Explore', 0)

    if read_count > 20 and explore_count == 0:
        # Count sessions with 10+ consecutive reads
        exploration_sessions = count_sessions_with_pattern(
            history,
            pattern=['Read', 'Read', 'Read', ...]  # 10+ reads
        )

        if exploration_sessions >= 3:
            inefficiencies.append({
                'type': 'manual_exploration',
                'severity': 'high',
                'count': exploration_sessions,
                'suggestion': 'Use Explore agent',
                'token_waste': exploration_sessions * 15000
            })

    # Pattern 2: Repeated searches
    grep_patterns = extract_grep_patterns(history)
    for pattern, occurrences in grep_patterns.items():
        if len(occurrences) >= 3:
            inefficiencies.append({
                'type': 'repeated_search',
                'severity': 'medium',
                'pattern': pattern,
                'count': len(occurrences),
                'suggestion': f'Create /find-{slugify(pattern)} command',
                'token_waste': len(occurrences) * 200
            })

    # Pattern 3: Manual git workflows
    git_commands = count_bash_pattern(history, r'^git ')
    commit_skill_usage = command_calls.get('/commit', 0)

    if git_commands > 10 and commit_skill_usage == 0:
        inefficiencies.append({
            'type': 'manual_git',
            'severity': 'medium',
            'count': git_commands,
            'suggestion': 'Use /commit skill or git-advanced-workflows',
            'token_waste': git_commands * 100
        })

    # Pattern 4: Complex multi-step prompts
    complex_prompts = count_prompts_over_length(history, min_words=100)
    seq_thinking_usage = mcp_calls.get('sequential-thinking', 0)

    if complex_prompts > 3 and seq_thinking_usage == 0:
        inefficiencies.append({
            'type': 'complex_reasoning',
            'severity': 'low',
            'count': complex_prompts,
            'suggestion': 'Enable sequential-thinking MCP',
            'token_waste': 'unknown'
        })

    # Sort by severity and token impact
    return sorted(inefficiencies, key=lambda x: (
        severity_score(x['severity']),
        x.get('token_waste', 0)
    ), reverse=True)
```

**Heuristics Table:**

| Pattern | Detection | Threshold | Suggestion |
|---------|-----------|-----------|------------|
| Manual exploration | Read calls without Explore | >20 reads, 0 Explore uses | Use Explore agent |
| Repeated searches | Same Grep pattern | ≥3 times | Create custom command |
| Manual git | Bash git commands | >10 commands, 0 /commit | Use git skills |
| Complex reasoning | Long prompts | >3 prompts >100 words | Use sequential-thinking |
| Sequential edits | Edit calls in sequence | >5 edits on same file | Use MultiEdit or compound skills |
| Unused agents | Installed but 0 invocations | Never used in period | Consider removing |

**Output:**
- List of detected inefficiencies
- Severity ratings (high/medium/low)
- Estimated token waste
- Specific suggestions

#### Recommendation Engine

**Responsibility:** Match unused capabilities to observed patterns

**Matching Algorithm:**

```python
def generate_recommendations(available, used, inefficiencies):
    recommendations = []

    # Get list of unused capabilities
    used_names = {u.name for u in used}
    unused = [cap for cap in available if cap.name not in used_names]

    # Match each unused capability to detected patterns
    for capability in unused:
        score, reason, benefit = match_capability_to_pattern(
            capability,
            inefficiencies
        )

        if score > 0.5:  # Threshold for recommendation
            recommendations.append({
                'capability': capability.name,
                'type': capability.type,
                'score': score,
                'reason': reason,
                'benefit': benefit,
                'effort': estimate_effort(capability),
                'priority': calculate_priority(score, benefit, effort)
            })

    # Sort by priority (impact / effort ratio)
    return sorted(recommendations, key=lambda r: r['priority'], reverse=True)


def match_capability_to_pattern(capability, inefficiencies):
    # Rule-based matching

    if capability.name == 'Explore':
        manual_exploration = find_inefficiency(inefficiencies, 'manual_exploration')
        if manual_exploration:
            return (
                0.95,  # high confidence match
                f"You manually read files {manual_exploration.count} times",
                f"Save ~{manual_exploration.token_waste} tokens"
            )

    if capability.type == 'skill' and 'git' in capability.name:
        manual_git = find_inefficiency(inefficiencies, 'manual_git')
        if manual_git:
            return (
                0.80,
                f"You ran {manual_git.count} git commands manually",
                "Faster git workflows, fewer prompts"
            )

    if capability.name == 'sequential-thinking':
        complex_reasoning = find_inefficiency(inefficiencies, 'complex_reasoning')
        if complex_reasoning:
            return (
                0.75,
                f"{complex_reasoning.count} complex multi-step prompts detected",
                "Better structured reasoning"
            )

    # Default: low priority for generic unused tools
    return (0.3, "Installed but unused", "May not be needed")


def calculate_priority(score, benefit, effort):
    # ROI calculation
    # benefit is token savings (numeric) or qualitative (string)

    benefit_score = parse_benefit(benefit)  # Convert to 0-1 scale
    effort_score = effort_minutes / 60      # Normalize to hours

    # Higher score, higher benefit, lower effort → higher priority
    return (score * benefit_score) / max(effort_score, 0.1)
```

**Output:**
- Prioritized list of recommendations
- Each with: capability, reason, benefit, effort, priority score

---

### 3. Report Generator

**Responsibility:** Format analysis into readable markdown

**Report Structure:**

```markdown
# Workflow Analysis Report
[Metadata: period, sessions, tokens]

## 1. Usage Summary
[Tables: top tools, agents, commands]
[Charts: usage distribution]

## 2. Capability Inventory
[Table: all capabilities with usage status]
[Highlight: Never used vs frequently used]

## 3. Workflow Inefficiencies
[For each inefficiency:]
  - **Title** (severity)
  - Finding (what was detected)
  - Pattern (specific examples)
  - Recommendation (what to do)
  - Impact (token savings estimate)

## 4. Underutilized Capabilities
[For each recommendation:]
  - **Capability name** (type)
  - Why you need it (reason)
  - What it does (description)
  - How to use (invocation example)
  - Expected benefit (concrete impact)

## 5. Action Items
[Prioritized list:]
  1. [High priority] Do X (effort, impact)
  2. [Medium priority] Do Y (effort, impact)
  ...

## Next Steps
[How to act on recommendations]
[How to re-run analysis]
```

**Formatting Tools:**
- Markdown tables for structured data
- Code blocks for examples
- Bold/italics for emphasis
- Emojis for visual scanning (optional)

---

## Data Flow Diagram

```
USER INPUT → AGENT
    │
    ├─→ TIME WINDOW PARSING
    │   └─→ "last 7 days" → start_date, end_date
    │
    ├─→ DATA COLLECTION
    │   ├─→ Inventory Scanner
    │   │   ├─→ Glob ~/.claude/commands → commands[]
    │   │   ├─→ Glob ~/.claude/agents → agents[]
    │   │   ├─→ Find plugins → skills[]
    │   │   └─→ jq settings.json → mcpServers[]
    │   │
    │   └─→ History Parser
    │       ├─→ Read history.jsonl
    │       ├─→ Filter by date range
    │       ├─→ Extract tool_use events → toolCalls[]
    │       ├─→ Extract agent invocations → agentCalls[]
    │       └─→ Extract command invocations → cmdCalls[]
    │
    ├─→ ANALYSIS
    │   ├─→ Usage Analyzer
    │   │   ├─→ Calculate frequencies
    │   │   ├─→ Attribute tokens
    │   │   └─→ Percentile analysis
    │   │
    │   ├─→ Pattern Detector
    │   │   ├─→ Apply heuristic rules
    │   │   ├─→ Score inefficiencies
    │   │   └─→ Estimate token waste
    │   │
    │   └─→ Recommendation Engine
    │       ├─→ Match unused to patterns
    │       ├─→ Score recommendations
    │       └─→ Prioritize by ROI
    │
    └─→ REPORT GENERATION
        ├─→ Format markdown sections
        ├─→ Create tables
        ├─→ Add examples
        └─→ Output to terminal
```

---

## Technology Stack

**Runtime:** Claude Code agent (runs within cc chat session)

**Tools Used:**
- **Read** - Parse JSON/JSONL files, read settings
- **Glob** - Discover files across directories
- **Grep** - Search for patterns in history
- **Bash** - Execute shell commands (jq, wc, date calculations)
- **TodoWrite** - Structure complex analysis tasks (optional)

**No External Dependencies:**
- No npm/pip packages required
- No Docker containers
- No databases
- Pure Claude Code built-in tools

---

## Performance Considerations

**Expected Execution Time:**
- Inventory scan: ~3 seconds (few hundred files)
- History parsing: ~10 seconds (depends on history size)
- Analysis: ~10 seconds (computation)
- Report generation: ~5 seconds (formatting)
- **Total: ~30 seconds** for typical usage

**Token Consumption:**
- Input tokens: ~10k (reading files, settings)
- Output tokens: ~5k (generating report)
- **Total: ~15k tokens per analysis** (acceptable for manual invocation)

**Scalability:**
- History.jsonl can grow large (>10MB)
- Mitigation: Filter by time window first (reduce dataset)
- For very large histories: Consider sampling or incremental analysis

---

## Error Handling

**Missing Data Sources:**
```python
if not exists('~/.claude/history.jsonl'):
    return "Error: No history.jsonl found. Have you used Claude Code before?"

if history.empty():
    return "No sessions found in specified time period."
```

**Invalid Time Windows:**
```python
try:
    start_date = parse_time_window(user_input)
except ParseError:
    return "Could not parse time window. Use: 'last 7 days', 'last month', etc."
```

**Corrupted JSON:**
```python
try:
    history = parse_jsonl(history_file)
except JSONDecodeError as e:
    return f"Corrupted history file at line {e.lineno}. Skipping invalid entries."
```

---

## Security & Privacy

**No External Data Transfer:**
- All analysis happens locally
- No API calls to external services
- History data never leaves user's machine

**Respects Project Boundaries:**
- Project-specific analysis uses only that project's history
- Global analysis aggregates across all projects
- No cross-project recommendations without user consent

**Sensitive Data:**
- History may contain API keys, passwords in prompts
- Agent should NOT log or expose history content
- Reports show aggregated statistics only, not raw history

---

## Limitations

**What This Agent CANNOT Do:**

1. **Real-time monitoring** - Only post-hoc analysis
2. **Automatic optimization** - Suggests changes, doesn't apply them
3. **Predictive analysis** - No forecasting of future token usage
4. **Cross-machine aggregation** - Works on single machine's history
5. **Fine-grained token attribution** - Estimates only, not exact measurements

**Future Enhancements:**

- Integration with Claude Viewer for visual dashboards
- Export reports to CSV/JSON for trend analysis
- Comparison mode (this month vs last month)
- Plugin-specific analysis (deep dive into specific plugins)
- Custom heuristics (user-defined inefficiency rules)

---

## Testing Strategy

**Unit Testing (Manual Verification):**
1. Test inventory scanner with known directory structure
2. Test history parser with sample history.jsonl
3. Verify pattern detection with crafted usage scenarios
4. Validate recommendation engine matches

**Integration Testing:**
1. Run on real history.jsonl from different time periods
2. Compare recommendations to manual observations
3. Verify token estimates are reasonable (within 20% of actual)

**Acceptance Criteria:**
- ✅ Identifies all installed capabilities
- ✅ Correctly parses history for time window
- ✅ Detects at least 3 common inefficiency patterns
- ✅ Generates actionable recommendations
- ✅ Completes analysis in <60 seconds
- ✅ Token consumption <20k per run

---

## Deployment Model

**Installation:**
1. Copy `workflow-analyzer.md` to `~/.claude/agents/`
2. No additional setup required

**Invocation:**
```bash
cc chat -a workflow-analyzer "Analyze my last 7 days"
cc chat -a workflow-analyzer "Full audit"
cc chat -a workflow-analyzer "What am I not using?"
```

**Updates:**
- Edit `~/.claude/agents/workflow-analyzer.md` directly
- No restart required
- Changes take effect on next invocation

---

## Success Metrics (Post-Deployment)

**After 1 month of usage:**

**Adoption:**
- ✅ User runs analysis at least weekly
- ✅ User acts on at least 50% of high-priority recommendations

**Impact:**
- ✅ Measurable increase in Explore agent usage (from recommendations)
- ✅ Reduction in manual file reads (tracked in subsequent analyses)
- ✅ Higher utilization rate of installed capabilities (>50%)

**Quality:**
- ✅ Recommendations are relevant (user finds them valuable)
- ✅ Token waste estimates are accurate (within 20% margin)
- ✅ No false positives (suggestions that don't apply)

**Efficiency:**
- ✅ Analysis completes in <60 seconds
- ✅ Token cost <20k per run
- ✅ Reports are actionable (clear next steps)

---

## Next Steps

1. ✅ Complete architecture document (this file)
2. Write agent markdown file with instructions
3. Create deployment guide
4. Test with real history.jsonl data
5. Iterate based on findings
