# Workflow Analyzer - Executive Summary

## What We Designed

A **pull-based workflow analysis agent** that identifies underutilized Claude Code capabilities and detects workflow inefficiencies—solving the gap Scout discovered in the ecosystem.

---

## The Problem

You have no visibility into:
- Which installed tools/agents/skills are actually being used
- What workflow patterns waste tokens
- Which capabilities would improve efficiency but remain unused

**Existing tools** (Claude Viewer, History MCP) provide token tracking but **don't offer proactive optimization suggestions**.

---

## The Solution

**Workflow Analyzer Agent** - A stateless agent that:

1. **Scans** what capabilities you have installed (commands, agents, skills, MCPs)
2. **Parses** your history.jsonl to see what you actually use
3. **Detects** workflow anti-patterns (manual file reads when Explore exists, etc.)
4. **Recommends** unused capabilities that match your workflow patterns
5. **Reports** actionable insights with effort/impact estimates

---

## How It Works

```
USER INVOKES
    │
    ├─→ Scan available capabilities (~/.claude/*)
    ├─→ Parse usage history (history.jsonl)
    ├─→ Detect inefficiencies (pattern matching)
    ├─→ Match unused tools to patterns
    └─→ Generate markdown report
```

**Zero monitoring overhead** - No hooks, no background processes, no runtime impact.

---

## Example Insights

**Usage patterns:**
- "You used Read tool 147 times, Explore agent 3 times"
- "You ran 27 git commands manually, never used /commit skill"
- "sequential-thinking MCP installed 1 week ago, 0 uses"

**Inefficiency detection:**
- "8 sessions with 10+ file reads → Use Explore agent (save ~160k tokens)"
- "Searched for 'API endpoint' 8 times → Create /find-api command"
- "Manual git workflows 27 times → Use git-advanced-workflows skill"

**Recommendations:**
- "Enable Explore agent - you manually read files frequently"
- "Your complex multi-step prompts suggest sequential-thinking MCP would help"
- "git-advanced-workflows skill is installed but unused - try it for next rebase"

---

## Architecture Highlights

### Data Sources
- `~/.claude/history.jsonl` - Session history
- `~/.claude/{commands,agents,skills}/` - Available capabilities
- `~/.claude/settings.json` - Configuration (plugins, MCPs)
- `~/.claude/plugins/*/` - Plugin-provided capabilities

### Analysis Pipeline
1. **Inventory Scanner** - Discover all available tools
2. **Usage Analyzer** - Calculate frequency, token impact
3. **Pattern Detector** - Apply heuristics to find inefficiencies
4. **Recommendation Engine** - Match unused capabilities to patterns
5. **Report Generator** - Format actionable markdown

### Detection Heuristics

| Pattern | Threshold | Suggestion |
|---------|-----------|------------|
| Manual file exploration | >20 reads, 0 Explore uses | Use Explore agent |
| Repeated searches | Same pattern ≥3 times | Create custom command |
| Manual git workflows | >10 commands, 0 /commit | Use git skills |
| Complex reasoning | >3 long prompts | Use sequential-thinking |

---

## Implementation

**Type:** Agent (simplest option)
**File:** `~/.claude/agents/workflow-analyzer.md`
**Tools:** Read, Glob, Grep, Bash (jq), TodoWrite
**Model:** Sonnet (needs reasoning for pattern detection)
**Dependencies:** None (uses Claude Code built-in tools)

**Installation:**
```bash
cp workflow-analyzer.md ~/.claude/agents/
```

**Usage:**
```bash
cc chat -a workflow-analyzer "Analyze my last 7 days"
```

**Expected performance:**
- Execution time: ~30 seconds
- Token consumption: ~15k per analysis
- Report length: ~500 lines of markdown

---

## Key Design Decisions

### Why Agent (not MCP Server)?
- **Simpler:** Single markdown file vs Node.js/Python server
- **Faster to build:** 2-3 hours vs 6-8 hours
- **Pull-based:** User controls invocation
- **No dependencies:** Works with standard Claude Code tools
- **Evolvable:** Edit markdown file to tune heuristics

### Why Post-Hoc (not Real-Time)?
- **Zero overhead:** No runtime hooks consuming tokens
- **Aligns with plan.md:** "Pull-based visibility, not push-based monitoring"
- **Avoids claude-mem mistake:** Don't create overhead while measuring overhead
- **Manual invocation:** User decides when to analyze

### Why Heuristic-Based (not ML)?
- **Transparent:** Rules are understandable and tunable
- **Fast:** No model training or inference
- **Actionable:** Clear cause → effect → recommendation
- **Evolvable:** Add new rules as patterns emerge

---

## Deliverables

### 1. Specification (`workflow-analyzer-spec.md`)
- 50+ pages covering requirements, design, algorithms, examples
- Functional requirements (inventory, usage analysis, recommendations)
- Non-functional requirements (zero overhead, pull-based, privacy)
- Example output with full report structure

### 2. Architecture (`architecture.md`)
- System architecture diagram
- Component details (Scanner, Parser, Analyzer, Engine, Generator)
- Data flow diagrams
- Performance considerations (~30 sec, ~15k tokens)
- Error handling, security, limitations

### 3. Deployment Guide (`deployment-guide.md`)
- Installation instructions (copy file to ~/.claude/agents/)
- Usage examples (basic, focused, comparison analysis)
- Interpreting results (how to read each section)
- Optimization workflow (weekly cadence, monthly review)
- Troubleshooting (common issues and solutions)
- Integration with Claude Viewer, History MCP, Scout

### 4. This Summary
- Quick reference for what we designed
- High-level overview without implementation details

---

## What's Missing (For Implementation)

**Still need to create:**
1. **workflow-analyzer.md** - The actual agent file with instructions
   - YAML frontmatter (name, description, model)
   - Agent system prompt
   - Analysis instructions
   - Heuristic rules
   - Report template

**Implementation effort:** 1-2 hours (writing agent instructions)

**Testing effort:** 1 hour (run on real history.jsonl, verify output)

**Total to production-ready:** ~3-4 hours

---

## Next Steps

### To Complete This Task
1. ✅ Specification written
2. ✅ Architecture designed
3. ✅ Deployment guide created
4. ⏳ Create workflow-analyzer.md agent file (next)
5. ⏳ Test with real history.jsonl
6. ⏳ Update task-metadata.md with outcome

### To Deploy & Use
1. Copy workflow-analyzer.md to ~/.claude/agents/
2. Run: `cc chat -a workflow-analyzer "Analyze my last 7 days"`
3. Review report, act on top 1-2 recommendations
4. Re-run weekly to track progress

### To Measure Success (After 1 Month)
- Track tool usage changes (more Explore, less manual Read)
- Measure token savings (estimate from reports)
- Evaluate recommendation quality (were they helpful?)
- Iterate on heuristics based on feedback

---

## Why This Is Better Than Building "Observability Framework"

**Original roadmap.md proposed:**
- Token Usage Analytics System (continuous monitoring)
- Workflow Pattern Analysis (continuous tracking)
- Recommendation Engine (LLM-powered analysis)
- A/B Testing Framework (statistical testing)

**Problems with that approach:**
- ❌ Real-time monitoring creates overhead (claude-mem mistake)
- ❌ Continuous tracking consumes tokens
- ❌ Over-engineering for one-person workflow
- ❌ 4 phases, weeks of work, complex infrastructure

**Workflow Analyzer instead:**
- ✅ Post-hoc analysis (zero runtime overhead)
- ✅ Manual invocation (pull-based)
- ✅ Simple implementation (one agent file)
- ✅ 3-4 hours to production-ready
- ✅ Provides 80% of value with 20% of complexity

**TL;DR:** We designed the smart version of observability - analyze existing data when needed, not create new overhead collecting it.

---

## Files Generated

```
tasks/122025_workflow_analyzer/
├── 00-initial-query.md           # User's original request
├── task-metadata.md               # Task status and deliverables
├── workflow-analyzer-spec.md      # 50-page specification
├── architecture.md                # Technical design (23 pages)
├── deployment-guide.md            # Installation & usage (19 pages)
└── summary.md                     # This file (quick reference)
```

**Total documentation:** ~100 pages
**Ready for implementation:** Yes
**Estimated build time:** 3-4 hours
**Expected value:** High (fills ecosystem gap)

---

## Comparison to Existing Tools

| Feature | Workflow Analyzer | Claude Viewer | History MCP | OpenTelemetry |
|---------|------------------|---------------|-------------|---------------|
| **Token tracking** | Estimates | ✅ Exact | ❌ No | ✅ Exact |
| **Tool usage analytics** | ✅ Yes | ✅ Top 10 | Manual | ✅ Yes |
| **Underutilized detection** | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Workflow recommendations** | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Post-hoc analysis** | ✅ Yes | ✅ Yes | ✅ Yes | ❌ Real-time |
| **Zero overhead** | ✅ Yes | ⚠️ Web server | ✅ Yes | ❌ Docker |
| **Setup time** | 1 min | 15 min | 2 min | 2-3 hours |

**Unique value:** Only tool that suggests underutilized capabilities and detects workflow inefficiencies.

---

## Questions Answered

**"Should we build this ourselves?"**
→ Yes. No existing tool does this. Claude Viewer + custom agent is best approach.

**"What architecture should we use?"**
→ Stateless agent, post-hoc analysis, heuristic-based detection.

**"How much effort?"**
→ 3-4 hours to build, 1 minute to install, ~15k tokens per use.

**"Will this actually help?"**
→ Yes. Identifies concrete inefficiencies (20+ file reads when Explore exists) and suggests specific fixes.

**"Does this violate plan.md's 'no monitoring overhead' principle?"**
→ No. It's pull-based, manual invocation, zero runtime impact. Exactly what plan.md recommends.

---

## Recommendation

**Build this.** It fills a real gap in the ecosystem and aligns perfectly with plan.md's philosophy:
- Search first ✅ (Scout confirmed nothing exists)
- Pull-based visibility ✅ (manual invocation only)
- No monitoring overhead ✅ (post-hoc analysis)
- Simple implementation ✅ (one agent file)
- High value ✅ (actionable recommendations)

**Next action:** Implement workflow-analyzer.md agent file (1-2 hours).
