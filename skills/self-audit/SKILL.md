---
name: self-audit
description: Periodic self-audit of Claude Code configuration quality, effectiveness, and documentation currency
---

# Self-Audit Skill

This skill enables Claude (primarily Kim) to **run systematic audits** of Claude Code configuration to identify inefficiencies, stale documentation, and improvement opportunities.

## When This Skill Runs

### Scheduled Audits

**Weekly Self-Audit (Every Monday):**
- Review last week's Claude work
- Identify patterns in mistakes/successes
- Check for stale conventions/skills
- Quick token usage spot-check

**Monthly Documentation Refresh (First Monday of month):**
- Full configuration audit
- Fetch latest Claude Code documentation
- Check for new features/best practices
- Update agents/skills with new capabilities
- Comprehensive token analysis

### Triggered Audits

**Run audit immediately when:**
- User says "run self-audit" or "audit configuration"
- After major Claude Code version update
- User reports repeated inefficiency
- After implementing new conventions/skills (validate effectiveness)
- User asks "how can we improve Claude setup?"

---

## What This Skill Does

**Comprehensive configuration review:**
1. **Agent quality check:** Definitions current, tools appropriate, no token waste
2. **Skill effectiveness:** Clear instructions, usage patterns, value provided
3. **Convention compliance:** Are conventions being followed?
4. **Documentation currency:** CLAUDE.md files accurate, references valid
5. **Token efficiency:** Identify configuration bloat
6. **Effectiveness metrics:** Are improvements working?

**Output:** Structured report with findings and concrete recommendations.

---

## Instructions

### Phase 1: Configuration Inventory

**Scan all Claude Code configurations:**

```bash
# Global configuration
ls -la ~/.claude/agents/
ls -la ~/.claude/skills/
ls -la ~/.claude/conventions/
cat ~/.claude/CLAUDE.md

# Project configurations (if in project)
cat .claude/CLAUDE.md
ls -la .claude-sessions/ 2>/dev/null
```

**Create inventory:**
- Count agents, skills, conventions
- Note file sizes (potential token waste)
- Check for outdated references
- Identify unused configurations

### Phase 2: Agent Quality Check

**For each agent in `~/.claude/agents/`:**

**Validate structure:**
- [ ] YAML frontmatter present (name, description, tools, model)
- [ ] Description clear and accurate
- [ ] Tools list appropriate for agent purpose
- [ ] Model choice justified

**Check for inefficiencies:**
- [ ] Overly long agent definitions (>5000 tokens)
- [ ] Redundant instructions across agents
- [ ] Outdated tool references
- [ ] Few-shot examples still relevant

**Questions to ask:**
- Is this agent still needed? (Check usage)
- Could it be merged with similar agent?
- Are instructions clear or confusing?
- Does it reference latest Claude Code features?

### Phase 3: Skill Effectiveness Review

**For each skill in `~/.claude/skills/`:**

**Validate utility:**
- [ ] Is skill being used? (Check if provides value)
- [ ] Are instructions clear and actionable?
- [ ] Does it automate something worthwhile?
- [ ] Any user complaints about skill behavior?

**Check for improvements:**
- [ ] Could trigger conditions be more accurate?
- [ ] Are examples current and helpful?
- [ ] Does it reference latest docs/conventions?
- [ ] Any way to reduce complexity?

**Questions to ask:**
- Would skill benefit from recent Claude Code features?
- Is it solving the right problem?
- Could it be combined with other skills?

### Phase 4: Convention Compliance

**Review conventions in `~/.claude/conventions/`:**

**Check adoption:**
- [ ] Are conventions being followed in practice?
- [ ] Are they referenced in project CLAUDE.md files?
- [ ] Do they solve real problems or just theoretical?
- [ ] Any conventions superseded by newer approaches?

**Validate currency:**
- [ ] Do conventions align with latest Claude Code best practices?
- [ ] Are examples still relevant?
- [ ] Any broken references or outdated links?

### Phase 5: Documentation Currency

**Global documentation:**
```bash
cat ~/.claude/CLAUDE.md
```

**Check:**
- [ ] References to conventions/skills accurate
- [ ] Task workflow instructions current
- [ ] Any stale TODOs or outdated guidance

**Project documentation (if in project):**
```bash
cat .claude/CLAUDE.md
cat CLAUDE.md
```

**Check:**
- [ ] "Pending Work" section current
- [ ] Completed items marked done
- [ ] References to commits/tasks valid
- [ ] Project-specific conventions documented

### Phase 6: Token Efficiency Analysis

**Calculate configuration overhead:**

```bash
# Count lines in agent definitions
wc -l ~/.claude/agents/*.md

# Count lines in skills
find ~/.claude/skills -name "*.md" -exec wc -l {} +

# Estimate tokens (rough: 1 token ≈ 0.75 words, avg 6 chars/word)
# For accurate count, would need tokenizer
```

**Identify token waste:**
- Agents >500 lines (review for bloat)
- Skills with excessive examples
- Redundant documentation across files
- Oversized few-shot examples

**Calculate overhead:**
- Total agent tokens loaded per session
- Total skill tokens (amortized by usage)
- Convention tokens (referenced, not loaded)

### Phase 7: Effectiveness Metrics

**Review improvements over time:**

**Context recovery incidents:**
- Before git-context-recovery skill: How many "what are you referring to?" incidents?
- After: Reduction in context clarification loops?

**Token usage trends:**
- Week-over-week token consumption
- Is configuration overhead growing or shrinking?
- Are optimizations having measurable impact?

**Task completion efficiency:**
- Average time to complete similar tasks
- Number of iterations needed
- User satisfaction indicators (fewer corrections, less frustration)

**If metrics unavailable, note:** "Recommend tracking these metrics going forward"

### Phase 8: Documentation Refresh (Monthly only)

**Check Claude Code documentation for updates:**

```bash
# Use WebSearch or WebFetch
```

Search for:
- "Claude Code documentation 2025"
- "Claude Code latest features"
- "Claude Code agents best practices"
- "Claude Code skills guide"

**Compare with current working knowledge:**
- New tools available for agents?
- Agent/skill syntax changes?
- New best practices or patterns?
- Deprecated features to remove?

**If updates found:**
- Update relevant agents/skills
- Add deprecation warnings
- Log changes in lessons-learned

### Phase 9: Generate Audit Report

**Format:**
```markdown
# Self-Audit Report - [Date]

## Executive Summary
[2-3 sentences: Overall health, key findings, priority recommendations]

## Configuration Inventory
- Agents: [count]
- Skills: [count]
- Conventions: [count]
- Total estimated token overhead: ~[X] tokens

## Findings

### Agent Quality
- ✅ [Good practices found]
- ⚠️ [Issues identified]
- 💡 [Optimization opportunities]

### Skill Effectiveness
- ✅ [Working well]
- ⚠️ [Issues or underutilized skills]
- 💡 [Enhancement ideas]

### Convention Compliance
- ✅ [Conventions being followed]
- ⚠️ [Conventions ignored or stale]
- 💡 [New conventions needed]

### Documentation Currency
- ✅ [Current and accurate]
- ⚠️ [Stale or outdated]
- 💡 [Updates needed]

### Token Efficiency
- Current overhead: ~[X] tokens per session
- Identified waste: ~[Y] tokens
- Optimization potential: ~[Z]% reduction

### Effectiveness Metrics
- Context recovery incidents: [trend]
- Token usage trend: [improving/stable/degrading]
- Task completion efficiency: [assessment]

## Recommendations

### High Priority
1. [Specific actionable recommendation]
2. [Another high-priority fix]

### Medium Priority
1. [Improvement that would help]
2. [Another enhancement]

### Low Priority / Future
1. [Nice-to-have improvement]
2. [Long-term enhancement]

## Documentation Updates

[If monthly audit:]
- Checked Claude Code docs: [date]
- New features found: [list or "none"]
- Updates applied: [list or "none pending"]

## Next Audit

- Weekly audit: [next Monday date]
- Monthly audit: [first Monday of next month]

---

*Audit completed by: [agent name]*
*Audit duration: [X] minutes*
*Total findings: [count]*
```

### Phase 10: Update Lessons-Learned

**Add audit findings to lessons-learned.md:**

```markdown
## [Date] - Self-Audit Findings

**Audit Type:** [Weekly/Monthly/Triggered]

**Key Discoveries:**
- [Pattern or issue discovered]
- [Optimization opportunity]
- [Effectiveness validation]

**Actions Taken:**
- [Fix implemented]
- [Documentation updated]
- [New convention/skill created]

**Impact:**
- [Measurable improvement]
- [Token savings]
- [Quality enhancement]

**Tags:** #self-audit #configuration-quality #continuous-improvement
```

---

## Example Audit Outputs

### Example 1: Weekly Audit (Quick Check)

```markdown
# Self-Audit Report - 2025-12-23 (Weekly)

## Executive Summary
Configuration healthy overall. Identified one stale agent and token optimization opportunity in kim-v2 agent. No urgent issues.

## Configuration Inventory
- Agents: 6
- Skills: 8
- Conventions: 4
- Total estimated token overhead: ~4200 tokens

## Findings

### Agent Quality
- ✅ All agents have valid YAML frontmatter
- ✅ Tool assignments appropriate
- ⚠️ agent-persona-requirements-analyst.md hasn't been used in 3 weeks
- 💡 kim-v2.md is 450 lines - could trim 50 lines from examples

### Skill Effectiveness
- ✅ git-context-recovery used 3 times this week (working well)
- ✅ session-notes-writer triggered appropriately (no over-suggesting)
- ⚠️ developer-growth-analysis hasn't been used in 2 months

### Convention Compliance
- ✅ task-workflow convention followed in current project
- ✅ context-recovery convention being applied

### Documentation Currency
- ✅ Global CLAUDE.md accurate
- ⚠️ Project CLAUDE.md "Pending Work" has 2 completed items not marked

### Token Efficiency
- Current overhead: ~4200 tokens per session
- Identified waste: ~100 tokens (kim-v2 examples)
- Optimization potential: ~2% reduction

## Recommendations

### High Priority
1. Update project CLAUDE.md to mark completed items
2. Verify if agent-persona-requirements-analyst is still needed

### Medium Priority
1. Trim kim-v2 examples to save ~50 tokens
2. Review developer-growth-analysis skill (archive if unused)

## Next Audit
- Weekly audit: 2025-12-30
- Monthly audit: 2026-01-06
```

---

### Example 2: Monthly Audit (Comprehensive)

```markdown
# Self-Audit Report - 2026-01-06 (Monthly)

## Executive Summary
Strong overall configuration. New Claude Code features available (extended context, improved tool calling). Identified 600 token optimization opportunity. Recommend adopting new features and retiring 1 deprecated skill.

## Configuration Inventory
- Agents: 6
- Skills: 8
- Conventions: 4
- Total estimated token overhead: ~4500 tokens

## Findings

### Agent Quality
- ✅ All agents current and well-structured
- ✅ Tool usage appropriate
- ⚠️ kim-v2.md references old WebSearch syntax (now deprecated)
- 💡 New tools available: PlanExecute, MultiRead (batch file reading)

### Skill Effectiveness
- ✅ git-context-recovery: 12 uses this month, 0 failures (excellent)
- ✅ session-notes-writer: Triggered 8 times, user satisfaction high
- ⚠️ create-agent-skills: Complex router skill rarely used
- 💡 Could simplify skill structure with new PlanExecute tool

### Convention Compliance
- ✅ All 4 conventions actively used
- ✅ No compliance gaps
- 💡 New convention opportunity: Multi-agent collaboration patterns

### Documentation Currency
- ✅ Global CLAUDE.md accurate
- ✅ Project CLAUDE.md files current
- ⚠️ 2 skills reference old docs.claude.com URLs (updated URLs available)

### Token Efficiency
- Current overhead: ~4500 tokens per session
- Identified waste: ~600 tokens
  - kim-v2 examples: ~100 tokens
  - Deprecated WebSearch syntax explanations: ~200 tokens
  - create-agent-skills router overhead: ~300 tokens
- Optimization potential: ~13% reduction

### Effectiveness Metrics
- Context recovery incidents: Decreased 85% since git-context-recovery deployment
- Token usage trend: Stable (configuration overhead unchanged)
- Task completion efficiency: Improved ~20% (measured by git commits per session)

## Recommendations

### High Priority
1. **Update WebSearch usage in kim-v2.md** (deprecated syntax)
2. **Adopt new MultiRead tool** for batch file operations (token savings)
3. **Update skill doc URLs** to new Claude Code documentation structure

### Medium Priority
1. **Simplify create-agent-skills** using PlanExecute tool (save ~300 tokens)
2. **Trim kim-v2 examples** to essential patterns (~100 token savings)
3. **Consider multi-agent collaboration convention** (emerging pattern)

### Low Priority / Future
1. Explore extended context feature for larger agent definitions
2. Create effectiveness metrics dashboard (track trends automatically)

## Documentation Updates

- Checked Claude Code docs: 2026-01-06
- New features found:
  - Extended context (now 300K tokens available)
  - PlanExecute tool (structured multi-step execution)
  - MultiRead tool (batch file reading)
  - Improved tool calling (lower latency)
- Deprecated:
  - Old WebSearch syntax (query parameter format changed)
  - Some MCP server patterns (new architecture)

**Actions taken:**
- [X] Updated kim-v2.md WebSearch syntax
- [X] Updated skill documentation URLs
- [ ] Pending: Refactor create-agent-skills with PlanExecute
- [ ] Pending: Adopt MultiRead in file-heavy skills

## Next Audit
- Weekly audit: 2026-01-13
- Monthly audit: 2026-02-03

---

*Audit completed by: kim-v2*
*Audit duration: 18 minutes*
*Total findings: 11 (3 high, 5 medium, 3 low priority)*
```

---

## Best Practices

### For Claude (Running Audits)

**DO:**
- Run audits systematically (follow all phases)
- Provide concrete, actionable recommendations
- Quantify findings (token counts, usage stats)
- Update lessons-learned with patterns discovered
- Prioritize recommendations (high/medium/low)

**DON'T:**
- Skip phases (comprehensive audit required)
- Give vague recommendations ("improve docs")
- Ignore metrics (measure effectiveness)
- Forget to check for Claude Code updates (monthly)
- Leave findings unaddressed (create action items)

### For Users

**To trigger audit:**
- "Run self-audit" (full audit)
- "Quick config check" (abbreviated audit)
- "Check for Claude Code updates" (documentation refresh only)

**After audit:**
- Review recommendations
- Approve high-priority fixes
- Schedule medium-priority improvements
- Archive or defer low-priority enhancements

---

## Integration with Lessons-Learned

Every audit updates `~/.claude/knowledge/lessons-learned.md`:

**After audit completion:**
1. Add findings to "Active Improvement Backlog"
2. Document patterns discovered
3. Note effectiveness of previous improvements
4. Update audit schedule tracking

**Example entry:**
```markdown
## 2026-01-06 - Monthly Self-Audit

**Findings:**
- git-context-recovery reduced context recovery incidents by 85%
- Token optimization opportunity: 600 tokens (~13% of overhead)
- New Claude Code features available (PlanExecute, MultiRead)

**Actions:**
- Updated WebSearch syntax across agents
- Created action items for PlanExecute adoption
- Scheduled skill refactor to use new tools

**Impact:**
- Validated context recovery system effectiveness (high value)
- Identified next optimization target (skill complexity)

**Tags:** #self-audit #metrics #documentation-refresh
```

---

## Related Skills & Conventions

- **Knowledge:** `~/.claude/knowledge/lessons-learned.md` - Audit schedule and checklist
- **Convention:** `~/.claude/conventions/context-recovery.md` - One system audited for effectiveness
- **Agent:** `kim-v2` - Primary agent responsible for running audits

---

**This skill enables continuous improvement through systematic self-reflection and configuration optimization.**
