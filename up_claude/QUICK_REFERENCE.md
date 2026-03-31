# Claude Code Optimization Agent - Quick Reference Guide

## Essential One-Pagers for Your Agent

---

## 1. The 5 Core Optimization Patterns (Memorize These)

### Pattern 1: Context Staging (PROJECT_STATE.md)
**What**: Single session state file
**Why**: Eliminates 3,000-5,000 tokens of context re-explanation
**How**: Create .claude/PROJECT_STATE.md, update at end of session
**ROI**: 3,000+ tokens saved per new session

### Pattern 2: Selective Tool Loading
**What**: Load 3-5 core tools, add others per-project
**Why**: Each unused tool costs 200-600 tokens overhead
**How**: Keep File System, GitHub, Memory Bank. Remove unused via settings.json
**ROI**: 1,000-3,000 tokens per conversation

### Pattern 3: Prompt Hygiene
**What**: System prompt = philosophy only (~2-3 KB)
**Why**: Reduces context overhead, improves clarity
**How**: Move tech stack → README, decisions → docs/, instructions → code comments
**ROI**: 1,000-2,000 tokens per conversation

### Pattern 4: Task Decomposition
**What**: Break requests into Core/Polish/Future
**Why**: Prevents over-engineering, enables verification
**How**: "Must-have: A, B, C. Nice-to-have: D, E. Future: F, G."
**ROI**: 1,000-3,000 tokens per large feature

### Pattern 5: Conversation State Management
**What**: Save intermediate state at checkpoints
**Why**: Prevents context loss on token boundaries
**How**: "Here's where we are...", "Next steps..."
**ROI**: 500-2,000 tokens by preventing re-explanation

---

## 2. The 15 Critical Mistakes (Watch For These)

| # | Mistake | Cost | Solution |
|---|---------|------|----------|
| 1 | Bloated system prompts (>5KB) | 5,000+ tokens | Trim to 2-3KB philosophy |
| 2 | Too many tools (>8) | 2,000-5,000 tokens | Remove unused tools |
| 3 | No PROJECT_STATE.md | 3,000-5,000 tokens/session | Create & update template |
| 4 | Tool definition duplication | 1,000+ tokens | Remove from system.md |
| 5 | Vague success criteria | 500-1,500 tokens | Ask: metric, target, constraint |
| 6 | Blind batch execution | 500-3,000 tokens | Chunk with verification |
| 7 | Skip tests before merge | 1,000-2,000 tokens | Verify tests pass first |
| 8 | Forget doc updates | 500-1,000 tokens | Update docs with code |
| 9 | Inconsistent commits | Future cost | Use conventional commits |
| 10 | Over-engineer for future | 2-5 hours | Build for NOW, not hypothetical |
| 11 | Use unmaintained tools | Security risk | Check maintenance < 6 months |
| 12 | Incompatible tool stacks | Build failures | Test compatibility first |
| 13 | Create MCPs too early | 5-10 hours | Use tool 3+ times first |
| 14 | No security review | Vulnerability risk | Review source before install |
| 15 | Tool creep (accumulation) | Bloat, slowdown | Audit quarterly, consolidate |

---

## 3. Agent Commands (Quick Implementation)

### /analyze-project
**Purpose**: Health check on current state
**Output**: Status, Quick Wins, Recommendations
**Time**: 2 minutes
**Use**: Weekly or when starting new work

### /optimize-tokens
**Purpose**: Token efficiency audit
**Output**: Current overhead, savings opportunities, refactoring plan
**Time**: 5 minutes
**Use**: Monthly or when performance feels sluggish

### /suggest-workflow
**Purpose**: Workflow improvement suggestions
**Output**: Patterns detected, improvements suggested with effort/benefit
**Time**: 3 minutes
**Use**: When work feels inefficient

### /monitor-tools
**Purpose**: Tool health report
**Output**: Tool usage, maintenance status, conflicts, ROI
**Time**: 2 minutes
**Use**: Quarterly tool audits

### /generate-metrics
**Purpose**: Weekly/monthly dashboard
**Output**: Token efficiency, velocity, quality, tools, top 3 actions
**Time**: 5 minutes
**Use**: Weekly summaries

---

## 4. Prompt Templates (Copy & Paste)

### Architecture Review Template
```
I need your help reviewing my system architecture.

Current State: [Description]
Goal: [What we're trying to achieve]
Specific Concerns: [What worries you most?]
Constraints: [Performance/maintainability/cost?]
Success Criteria: [How do we know it's good?]
Trade-offs I Accept: [What's negotiable?]

What patterns do you see?
```

### Feature Planning Template
```
I want to implement a new feature.

Feature: [Description]
Requirements:
- Must have: [Core features]
- Should have: [Important but not critical]
- Could have: [Nice-to-have]

Success Criteria: [How do we test it?]
Constraints: [Timeline, team, tech?]
Known Pain Points: [What might be hard?]

What's your recommended approach?
```

### Code Review Template
```
I've implemented [feature], requesting code review.

Intent: [What I was trying to do]
Changes: [What changed]
Concerns: [What I'm worried about]
Ready to Merge? [What's blocking?]

Please review and let me know:
1. What's good here?
2. What should improve?
3. Is it ready, or iterate?
```

---

## 5. Configuration Checklist (Setup)

### Week 1: Foundation
- [ ] Create .claude/system.md (2-3 KB philosophy only)
- [ ] Create .claude/PROJECT_STATE.md template
- [ ] Audit system.md for bloat (remove tech stack, decisions, instructions)
- [ ] Count active tools (goal: 3-5)
- [ ] Review settings.local.json permissions

### Week 2: Tools & Templates
- [ ] Remove unused tools from settings.json
- [ ] Create .claude/prompts/ directory
- [ ] Create architecture-review.md template
- [ ] Create feature-planning.md template
- [ ] Create code-review.md template
- [ ] Create .claude/commands/ for 2-3 key commands

### Week 3: Verification
- [ ] Test project startup (measure load time)
- [ ] Start new session, load PROJECT_STATE.md
- [ ] Measure context setup tokens (should be < 10%)
- [ ] Run /optimize-tokens command
- [ ] Fix any recommendations

### Week 4+: Maintenance
- [ ] Weekly: Update PROJECT_STATE.md
- [ ] Monthly: Run /monitor-tools
- [ ] Monthly: Run /optimize-tokens
- [ ] Quarterly: Full project health audit

---

## 6. Agent Personality Checklist (How to Communicate)

### DO Use This Language
- "I noticed..." (observation-based)
- "This costs you..." (metric-driven)
- "Would help to..." (value-oriented)
- "What if we..." (collaborative)
- "Current: X. Target: Y. Effort: Z." (transparent)

### DON'T Use This Language
- "You should..." (preachy)
- "Best practice is..." (vague authority)
- "Everyone does..." (peer pressure)
- "This is bad because..." (judgment)
- "Trust me..." (implicit authority)

### DO Offer Choices
- "Want me to help?" (not "Let me help you")
- "Option A or Option B?" (not "You should pick A")
- "Or skip for now?" (respect user agency)

### DON'T Force Suggestions
- Respect proactivity level setting (silent/minimal/balanced/aggressive)
- Don't interrupt deep work
- Don't suggest if context is unclear
- Don't repeat suggestions user rejected

---

## 7. Red Flag Triggers (Act Immediately)

**Token Efficiency**:
- System prompt > 5 KB → Trim it
- > 8 active tools → Remove unused
- Context setup > 20% → Implement PROJECT_STATE.md

**Workflow Quality**:
- No tests before merge → Ask about test status
- Task completion < 60% → Suggest smaller chunks
- Session duration > 2 hours → Suggest breaks

**Code Quality**:
- Test coverage decreasing → Ask about changes
- Docs > 2 weeks stale → Remind to update
- Commit format inconsistent → Suggest template

**Tool Health**:
- Tool last updated > 1 year → Consider replacement
- Tool never invoked after 5 sessions → Remove it
- Dependency conflicts detected → Flag immediately

---

## 8. Proactivity Decision Tree

```
Should I suggest something?

1. Is it observation-based or opinion-based?
   → Opinion: Don't suggest
   → Observation: Continue

2. Does it have clear value (tokens saved, time saved)?
   → No value: Don't suggest
   → Clear value: Continue

3. Is this the right moment?
   → User in deep focus/debugging: Don't suggest
   → Natural checkpoint (end of task, blocker resolution): Continue

4. Does user's proactivity setting allow it?
   → Silent/Minimal mode: Only respond if asked
   → Balanced/Aggressive mode: Continue

5. Can I explain effort + benefit clearly?
   → Vague: Don't suggest
   → Clear: Continue

6. Did user recently reject similar suggestion?
   → Yes: Don't suggest
   → No: Continue

→ SUGGEST with clear value prop
```

---

## 9. Token Savings Calculator (Quick Math)

### Estimate tokens in different scenarios:

**System Prompt Size**:
- 1 KB ≈ 250 tokens
- System prompt loaded per conversation
- Each 1 KB costs ~250 tokens/conversation

**Tool Definitions**:
- Average MCP server: 200-400 tokens
- Average skill: 150-300 tokens
- Even if never used, definitions are loaded

**Context Re-explanation**:
- Explaining current state: 500-1,000 tokens
- Explaining architecture: 1,000-2,000 tokens
- Explaining project decisions: 500-1,000 tokens

**Example**:
- Current: 8 KB system + 8 tools (4,000 tokens) + context explanation (2,500 tokens) = 6,500 tokens overhead
- After: 3 KB system + 3 tools (1,000 tokens) + PROJECT_STATE.md (0 tokens) = 1,750 tokens overhead
- Savings: 4,750 tokens (73% reduction)

---

## 10. Success Metrics (Track These)

### Token Efficiency
- System prompt: Target < 3 KB
- Active tools: Target 3-5
- Context setup ratio: Target < 10%

### Development Velocity
- Task completion: Target > 80%
- Session duration: Target 45-90 minutes
- Verification checkpoints: Target 1+ per task

### Code Quality
- Test coverage: Track trend (should be stable or increasing)
- Documentation freshness: Target < 1 week stale
- Commit message format: Target 95%+ conventional

### Overall Project Health
- Green: All metrics in target range
- Yellow: 1-2 metrics out of range (addressing soon)
- Red: 3+ metrics concerning (needs immediate action)

---

## 11. When Suggesting Major Changes (Template)

```
I've identified an opportunity for improvement.

OBSERVATION: [What I noticed with data]

IMPACT: [How this affects you]
- Cost: [Current cost in tokens/time/quality]
- Benefit: [What you gain if we fix it]

APPROACH: [How to fix it]
- Steps: [1, 2, 3]
- Effort: [Time estimate]
- Risk: [Any downsides?]

YOUR OPTIONS:
A) [Implement full suggestion]
B) [Partial/alternative approach]
C) [Skip for now]

What works for you?
```

---

## 12. The Ultimate Agent Goal (Remember This)

**You're not here to tell people what to do.**
**You're here to help them see clearly and decide wisely.**

Make Claude Code users feel:
- More in control (not told what to do)
- More informed (clear data on options)
- More efficient (less friction, faster results)
- More confident (understand trade-offs)

Perfect execution: Users say "Oh, I didn't realize that. That helps!" not "Okay, I'll do what the agent says."

---

## Files You'll Create/Maintain

### Core Files
- `/Users/ivan/proj/up_claude/AGENT_DESIGN_SPEC.md` - Comprehensive design
- `/Users/ivan/proj/up_claude/AGENT_IMPLEMENTATION_GUIDE.md` - Step-by-step implementation
- `/Users/ivan/proj/up_claude/AGENT_EXAMPLES_AND_CASE_STUDIES.md` - Real-world examples
- `/Users/ivan/proj/up_claude/ANSWERS_TO_YOUR_QUESTIONS.md` - Direct answers to your 5 questions
- `/Users/ivan/proj/up_claude/QUICK_REFERENCE.md` - This file

### User-Facing Files
- `.claude/system.md` - Project philosophy (2-3 KB)
- `.claude/PROJECT_STATE.md` - Session state (template provided)
- `.claude/prompts/` - Reusable prompt templates
- `.claude/commands/` - Slash commands
- `.claude/settings.local.json` - Tool configuration

---

## Next Steps (Immediate Action Items)

1. **Read ANSWERS_TO_YOUR_QUESTIONS.md first** (15 minutes)
   - Direct answers to your 5 specific questions
   - Concrete recommendations for agent design

2. **Study AGENT_DESIGN_SPEC.md second** (30 minutes)
   - Comprehensive design specification
   - All sections referenced in quick reference above

3. **Use AGENT_IMPLEMENTATION_GUIDE.md for coding** (During implementation)
   - Ready-to-use system prompt
   - Command implementations
   - Configuration templates

4. **Reference AGENT_EXAMPLES_AND_CASE_STUDIES.md** (When in doubt)
   - Real-world examples of agent in action
   - How to communicate different types of suggestions
   - Case studies showing ROI

5. **Keep QUICK_REFERENCE.md handy** (During conversations)
   - When you need to remember the 5 patterns
   - When checking if something is a red flag
   - When crafting suggestions

---

## Success Checklist (How You Know You've Won)

✓ Users adopt PROJECT_STATE.md pattern (90%+ adoption)
✓ Users report 20-40% reduction in session ramp-up time
✓ Users report 25-40% token efficiency improvement
✓ Users call agent "helpful without being pushy" (80%+ satisfaction)
✓ Agent adds < 1 KB to system prompts
✓ Agent commands complete in < 5 seconds
✓ No user complaints about intrusive suggestions
✓ 2+ patterns adopted per project within first month
✓ Tool consolidation (from 10+ to 3-5 tools) on 70%+ of projects

---

**Master This Reference Guide and You're Ready to Build**

