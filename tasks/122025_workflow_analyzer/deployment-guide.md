# Workflow Analyzer - Deployment Guide

## Quick Start

```bash
# 1. Copy agent file to ~/.claude/agents/
cp workflow-analyzer.md ~/.claude/agents/

# 2. Run analysis
cc chat -a workflow-analyzer "Analyze my last 7 days"
```

That's it. No dependencies, no configuration needed.

---

## Prerequisites

**Required:**
- Claude Code installed and configured
- At least some usage history (`~/.claude/history.jsonl` exists)

**Optional:**
- Multiple weeks of history for better pattern detection
- Claude Viewer installed (for complementary visual analytics)

---

## Installation

### Step 1: Create Agent File

**Option A: Copy from this repo**
```bash
cp /Users/ivan/proj/claude-configs/tasks/122025_workflow_analyzer/workflow-analyzer.md \
   ~/.claude/agents/workflow-analyzer.md
```

**Option B: Create manually**
```bash
# Create file
touch ~/.claude/agents/workflow-analyzer.md

# Open in editor and paste agent definition (see workflow-analyzer.md)
code ~/.claude/agents/workflow-analyzer.md
```

### Step 2: Verify Installation

```bash
# List available agents (should include workflow-analyzer)
ls ~/.claude/agents/

# Test invocation
cc chat -a workflow-analyzer "Test run"
```

---

## Usage

### Basic Invocations

```bash
# Analyze last 7 days (default)
cc chat -a workflow-analyzer "Analyze my last 7 days"

# Analyze last month
cc chat -a workflow-analyzer "Analyze last 30 days"

# Full historical analysis
cc chat -a workflow-analyzer "Analyze all time"
```

### Focused Analysis

```bash
# Check for unused capabilities
cc chat -a workflow-analyzer "What am I not using?"

# Find workflow inefficiencies
cc chat -a workflow-analyzer "Find inefficiencies in my workflow"

# Tool usage breakdown
cc chat -a workflow-analyzer "Which tools do I use most?"

# Project-specific analysis
cd /path/to/project
cc chat -a workflow-analyzer "Analyze this project only"
```

### Comparison Analysis

```bash
# Compare time periods
cc chat -a workflow-analyzer "Compare last week to this week"

# Before/after optimization
cc chat -a workflow-analyzer "Analyze since I enabled Explore agent"
```

---

## Expected Output

### Report Structure

The agent generates a markdown report with these sections:

1. **Usage Summary**
   - Time period, session count, token totals
   - Top 5 most-used tools/agents/commands
   - Usage frequency distribution

2. **Capability Inventory**
   - Table of all installed capabilities
   - Usage status (never/rare/occasional/frequent)
   - Last used date for each

3. **Workflow Inefficiencies**
   - Detected anti-patterns (manual work, repeated operations)
   - Severity ratings (high/medium/low)
   - Token waste estimates
   - Specific recommendations

4. **Underutilized Capabilities**
   - Unused but relevant tools/agents/skills
   - Why each would help your workflow
   - Installation/usage instructions
   - Expected benefits

5. **Action Items**
   - Prioritized list (top 3-5 changes)
   - Effort estimates (1 min / 5 min / 30 min)
   - Impact ratings (high/medium/low)

### Sample Output

```markdown
# Workflow Analysis Report
**Period:** 2025-12-13 to 2025-12-20 (7 days)
**Sessions:** 24
**Total tokens:** 487,392

---

## Usage Summary

### Most Used Tools
1. Read (147 uses) - 61% of sessions
2. Grep (83 uses) - 58% of sessions
3. Edit (56 uses) - 46% of sessions

### Most Used Agents
1. general-purpose (12 uses)
2. Explore (3 uses)

### Most Used Commands
1. /commit (8 uses)
2. /cluddha (4 uses)

---

## Workflow Inefficiencies

### HIGH: Excessive Manual File Reads
**Pattern:** 8 sessions with 10+ sequential file reads
**Token waste:** ~160k tokens
**Recommendation:** Use Explore agent for codebase discovery
**Example:** Session #12 - 23 files read to understand auth flow

### MEDIUM: Repeated Git Operations
**Pattern:** 27 manual git commands across 15 sessions
**Token waste:** ~2.7k tokens
**Recommendation:** Use /commit skill or git-advanced-workflows
**Example:** `git add . && git commit -m "..."` invoked 8 times

---

## Underutilized Capabilities

### 1. Explore Agent (Installed, rarely used)
**Why:** 8 manual exploration sessions detected
**How:** `cc chat -a Explore "medium" "Explain auth architecture"`
**Benefit:** Save ~20k tokens per exploration

### 2. sequential-thinking MCP (Installed, never used)
**Why:** 4 complex multi-step prompts detected
**How:** Already enabled in settings, just invoke when needed
**Benefit:** Better structured reasoning, fewer retries

---

## Action Items

1. **[HIGH] Use Explore for next codebase question** (1 min, high impact)
2. **[MEDIUM] Read git-advanced-workflows docs** (5 min, medium impact)
3. **[LOW] Try sequential-thinking on complex task** (1 min, low impact)

---

**Next run:** `cc chat -a workflow-analyzer "Analyze last 7 days"`
```

---

## Interpreting Results

### Usage Summary

**What to look for:**
- Are your most-used tools appropriate for your work?
- Are you over-relying on manual tools (Read, Grep) vs agents?
- Do command usage rates match your perception?

**Red flags:**
- Read tool >100 uses/week with 0 Explore uses → inefficiency
- Many Bash git commands with 0 /commit uses → inefficiency
- High general-purpose agent use with 0 specialized agent use → underutilization

### Capability Inventory

**What to look for:**
- Capabilities installed >1 month ago with 0 uses → consider removing
- Recently installed capabilities with high usage → good adoption
- Capabilities you forgot you had → revisit and evaluate

**Action triggers:**
- **Never used in 2+ weeks** → Disable or uninstall
- **Used 1-2 times in months** → Low value, consider removing
- **Used frequently** → Keep and optimize workflow around it

### Workflow Inefficiencies

**Severity ratings:**
- **HIGH:** >10k token waste, immediate action recommended
- **MEDIUM:** 1k-10k token waste, act within a week
- **LOW:** <1k token waste, act when convenient

**How to act:**
- Read the specific recommendation
- Try the suggested alternative in your next session
- Re-run analysis after 1 week to see improvement

### Underutilized Capabilities

**Recommendation confidence:**
- **0.9-1.0 score:** Strong pattern match, definitely try it
- **0.7-0.8 score:** Likely helpful, worth testing
- **0.5-0.6 score:** Possible fit, evaluate first
- **<0.5 score:** Weak match, not shown in report

**Testing recommendations:**
- Start with top 1-2 recommendations only
- Try each for 1 week
- Re-run analysis to measure impact
- Keep what works, discard what doesn't

---

## Optimization Workflow

### Weekly Cadence

**Every Monday (5 minutes):**
```bash
# Run analysis
cc chat -a workflow-analyzer "Analyze last 7 days"

# Review inefficiencies section
# Pick 1-2 action items to try this week
```

**Every Friday (2 minutes):**
```bash
# Quick check: Did I try the recommended tools?
# If yes, how did it feel?
# If no, why not? (too complex, not relevant, forgot)
```

### Monthly Review

**Every month (30 minutes):**
```bash
# Run comprehensive analysis
cc chat -a workflow-analyzer "Analyze last 30 days"

# Compare to previous month
# Identify trends (improving? regressing?)

# Update configuration based on findings:
# - Disable unused plugins
# - Enable recommended MCPs
# - Create custom commands for repeated patterns
```

### Measuring Success

**Track these metrics over time:**

| Metric | Baseline | After 1 month | After 3 months |
|--------|----------|---------------|----------------|
| Manual file reads per week | __ | __ | __ |
| Explore agent usage | __ | __ | __ |
| Unused capability % | __ | __ | __ |
| Manual git commands | __ | __ | __ |
| Token waste (estimated) | __ | __ | __ |

**Goal:** Downward trend on manual operations, upward trend on agent/skill usage.

---

## Troubleshooting

### "No history.jsonl found"

**Cause:** Claude Code history file doesn't exist
**Solution:** Use Claude Code for at least one session first

```bash
# Verify history file exists
ls -lh ~/.claude/history.jsonl

# If missing, run any Claude Code command
cc chat "Hello"
```

### "No sessions found in time period"

**Cause:** Requested time window has no data
**Solution:** Adjust time window or check history file

```bash
# Check history file size
wc -l ~/.claude/history.jsonl

# Try broader time window
cc chat -a workflow-analyzer "Analyze last 30 days"
```

### "Analysis takes too long (>2 minutes)"

**Cause:** Very large history.jsonl file (>50MB)
**Solution:** Narrow time window or archive old history

```bash
# Check history size
du -h ~/.claude/history.jsonl

# Archive old history
mv ~/.claude/history.jsonl ~/.claude/history.jsonl.archive
# Claude Code will create new history.jsonl
```

### "Recommendations don't seem relevant"

**Cause:** Pattern detection heuristics may not match your workflow
**Solution:** Provide feedback, adjust heuristics

```bash
# Run focused analysis
cc chat -a workflow-analyzer "Ignore git recommendations, focus on tools"

# Or edit agent instructions to tune heuristics
code ~/.claude/agents/workflow-analyzer.md
```

### "Token estimates seem off"

**Cause:** Estimates are rough heuristics, not exact measurements
**Solution:** Use Claude Viewer for accurate token tracking

```bash
# Install Claude Viewer for precise token data
git clone https://github.com/maxturazzini/claude-viewer.git
cd claude-viewer
npm install && npm start

# Then re-run workflow-analyzer with better baseline
```

---

## Integration with Other Tools

### Claude Viewer

**Use together:**
1. Run workflow-analyzer for recommendations
2. Use Claude Viewer for precise token tracking
3. Cross-reference findings

```bash
# Workflow analyzer: "You use Read tool 147 times"
# Claude Viewer: Shows exact token cost of those reads

# Combined insight: "147 reads cost 73k tokens, use Explore instead"
```

### History MCP

**Use together:**
1. workflow-analyzer identifies patterns
2. Use history MCP to drill into specific sessions

```bash
# Workflow analyzer: "8 sessions with 10+ file reads"
# Then query history MCP: "Show me session details for those 8 sessions"

cc chat
> Use history MCP to get sessions from Dec 13-20 with >10 Read calls
```

### Scout Agent

**Use together:**
1. workflow-analyzer recommends capability
2. Use Scout to find similar alternatives

```bash
# Workflow analyzer: "Enable sequential-thinking MCP"
# Scout: "Search for alternative reasoning MCPs"

cc chat -a Scout "Find MCPs for structured multi-step reasoning"
```

---

## Advanced Usage

### Custom Heuristics

Edit `~/.claude/agents/workflow-analyzer.md` to tune detection rules:

```markdown
# In the agent instructions section:

## Custom Heuristics

- Ignore git patterns (I prefer manual git)
- Flag any session with >50 Read calls as inefficient
- Recommend Explore agent only if >20 sequential reads in same directory
- Don't suggest MCP servers (I prefer agents)
```

### Project-Specific Analysis

```bash
# Analyze only a specific project
cd /path/to/project
cc chat -a workflow-analyzer "Analyze .claude/history for this project only"

# Compare project A vs project B
cc chat -a workflow-analyzer "Compare workflow patterns between projectA and projectB"
```

### Export Reports

```bash
# Save report to file
cc chat -a workflow-analyzer "Analyze last 30 days and save to workflow-report.md"

# Then process with other tools
cat workflow-report.md | grep "HIGH:" | wc -l  # Count high-severity issues
```

---

## Maintenance

### Updating the Agent

```bash
# Edit agent file
code ~/.claude/agents/workflow-analyzer.md

# Changes take effect immediately (no restart)

# Test update
cc chat -a workflow-analyzer "Test run"
```

### Version Control

```bash
# Track agent changes over time
cd ~/.claude/agents/
git init
git add workflow-analyzer.md
git commit -m "Initial workflow analyzer"

# After edits
git diff workflow-analyzer.md  # See what changed
git commit -am "Tuned heuristics for git patterns"
```

### Sharing with Team

```bash
# Export agent file
cp ~/.claude/agents/workflow-analyzer.md /path/to/shared/repo/

# Teammates can import
cp /path/to/shared/repo/workflow-analyzer.md ~/.claude/agents/
```

---

## Uninstallation

```bash
# Remove agent file
rm ~/.claude/agents/workflow-analyzer.md

# Verify removal
ls ~/.claude/agents/ | grep workflow-analyzer  # Should return nothing
```

No other cleanup needed (agent doesn't create persistent data).

---

## Next Steps

1. **Install:** Copy agent file to `~/.claude/agents/`
2. **Run:** `cc chat -a workflow-analyzer "Analyze my last 7 days"`
3. **Review:** Read the generated report
4. **Act:** Try top 1-2 recommendations
5. **Iterate:** Re-run analysis weekly to track progress

---

## Support

**Issues:**
- Check troubleshooting section above
- Review agent instructions in `~/.claude/agents/workflow-analyzer.md`
- Test with minimal history first (last 7 days)

**Feedback:**
- Edit agent file to tune for your workflow
- Share improvements with community
- Report bugs or suggestions via GitHub issues

**Documentation:**
- See `workflow-analyzer-spec.md` for detailed requirements
- See `architecture.md` for technical design
- See example output in this guide
