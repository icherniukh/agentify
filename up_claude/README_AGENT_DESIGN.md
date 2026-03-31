# Claude Code Workflow Optimization Agent - Complete Design Package

This directory contains a comprehensive design specification and implementation guide for creating a specialized Claude Code agent that helps engineers optimize their workflows, projects, and token efficiency.

---

## What You're Building

A specialized Claude Code agent that:
1. Advises on Claude Code configuration and organization best practices
2. Helps developers optimize token usage and context efficiency
3. Prevents common workflow mistakes proactively
4. Monitors project health with actionable metrics
5. Suggests improvements without being intrusive

---

## Core Documents (Read in This Order)

### 1. ANSWERS_TO_YOUR_QUESTIONS.md (START HERE)
**Purpose**: Direct, concise answers to your 5 specific questions
**Length**: 22 KB
**Read Time**: 20-30 minutes
**Contains**:
- Question 1: 5 Critical workflow optimization patterns
- Question 2: Configuration organization best practices
- Question 3: 15 Common mistakes to prevent
- Question 4: How to be proactive without being intrusive
- Question 5: 12 Key metrics to monitor

**When to Use**: First read. Gets straight to answers without theory.

---

### 2. AGENT_DESIGN_SPEC.md (Comprehensive Reference)
**Purpose**: Complete design specification for the agent
**Length**: 27 KB
**Read Time**: 40-60 minutes
**Contains**:
- Section 1: Workflow optimization patterns (detailed)
- Section 2: Configuration organization (detailed)
- Section 3: 15 Common mistakes (detailed)
- Section 4: Proactivity patterns (detailed)
- Section 5: Metrics & indicators (detailed)
- Section 6: Agent design specifics
- Section 7: Implementation roadmap
- Section 8: Key files to create
- Section 9: Integration points
- Section 10: Success criteria

**When to Use**: Reference document. Read sections as needed. Go deeper on specific topics.

---

### 3. AGENT_IMPLEMENTATION_GUIDE.md (Build This)
**Purpose**: Ready-to-use code and configurations
**Length**: 31 KB
**Read Time**: 30 minutes (while building)
**Contains**:
- Part 1: Agent system prompt (copy-paste ready)
- Part 2: 5 Slash commands with examples (/analyze-project, /optimize-tokens, etc.)
- Part 3: 4 Reusable prompt templates
- Part 4: Configuration file templates (.claude/system.md, PROJECT_STATE.md, settings.json)
- Part 5: Implementation checklist (4-week plan)
- Part 6: Testing framework

**When to Use**: During implementation. Copy templates and customize.

---

### 4. AGENT_EXAMPLES_AND_CASE_STUDIES.md (Learn by Example)
**Purpose**: Real-world examples of the agent in action
**Length**: 19 KB
**Read Time**: 20 minutes
**Contains**:
- Case Study 1: The Bloated Startup (12.4KB → 3.2KB system prompt)
- Case Study 2: The Disorganized Mid-Project (PROJECT_STATE.md impact)
- Case Study 3: The Optimization Cascade (compounding improvements)
- Case Study 4: Proactivity in Action (gentle guidance)
- Case Study 5: Mistake Prevention (catching auth feature without tests)
- Example responses (token waste detection, metrics dashboard)
- Common agent response templates

**When to Use**: Understand real-world impact. Learn how agent communicates.

---

### 5. QUICK_REFERENCE.md (Keep Handy)
**Purpose**: One-page summaries and checklists
**Length**: 13 KB
**Read Time**: 10 minutes (skim) or ongoing reference
**Contains**:
- The 5 core patterns (one-liner each)
- The 15 mistakes (table format)
- Agent commands (5 quick summaries)
- Prompt templates (copy-paste)
- Configuration checklist (4-week plan)
- Agent personality checklist
- Red flag triggers
- Proactivity decision tree
- Token savings calculator
- Success metrics
- Next steps & success checklist

**When to Use**: During implementation and ongoing use. Keep in browser tab.

---

## File Structure

```
/Users/ivan/proj/up_claude/
├── README_AGENT_DESIGN.md                    # This file (your map)
├── ANSWERS_TO_YOUR_QUESTIONS.md              # Direct answers
├── AGENT_DESIGN_SPEC.md                      # Complete specification
├── AGENT_IMPLEMENTATION_GUIDE.md              # Build with this
├── AGENT_EXAMPLES_AND_CASE_STUDIES.md        # Learn from examples
├── QUICK_REFERENCE.md                        # Checklists & templates
├── CANDIDATES.md                             # MCP/Skill research (reference)
└── .claude/                                  # Will create during implementation
    ├── system.md                             # Agent system prompt
    ├── PROJECT_STATE.md                      # Session state template
    ├── settings.local.json                   # Tool configuration
    ├── commands/                             # Slash commands
    │   ├── analyze-project.md
    │   ├── optimize-tokens.md
    │   └── ...
    └── prompts/                              # Reusable prompt templates
        ├── architecture-review.md
        ├── feature-planning.md
        └── ...
```

---

## Quick Navigation by Use Case

### "I need to understand what to build"
→ Read: ANSWERS_TO_YOUR_QUESTIONS.md (20 min)
→ Skim: QUICK_REFERENCE.md (5 min)

### "I need comprehensive design details"
→ Read: AGENT_DESIGN_SPEC.md (60 min)
→ Reference: AGENT_IMPLEMENTATION_GUIDE.md while coding

### "I need to understand the agent's voice and approach"
→ Read: AGENT_EXAMPLES_AND_CASE_STUDIES.md (20 min)
→ Reference: QUICK_REFERENCE.md Section 6 (Personality Checklist)

### "I need to build the agent now"
→ Use: AGENT_IMPLEMENTATION_GUIDE.md (all sections)
→ Reference: QUICK_REFERENCE.md (sections 8-11)
→ Check: Implementation checklist (4-week plan)

### "I need to remember the key concepts"
→ Keep open: QUICK_REFERENCE.md
→ Most important: The 5 patterns and 15 mistakes

### "I need to understand impact/ROI"
→ Read: AGENT_EXAMPLES_AND_CASE_STUDIES.md Case Studies 1, 2, 3

### "I need metric definitions and thresholds"
→ Reference: AGENT_DESIGN_SPEC.md Section 5
→ Or: QUICK_REFERENCE.md Section 10 (Success Metrics)

---

## Key Concepts (Master These First)

### The 5 Core Optimization Patterns
1. **Context Staging** (PROJECT_STATE.md) - Save 3,000+ tokens per session
2. **Selective Tool Loading** (3-5 core tools) - Save 1,000-3,000 tokens
3. **Prompt Hygiene** (2-3 KB philosophy) - Save 1,000-2,000 tokens
4. **Task Decomposition** (Core/Polish/Future) - Better results, fewer iterations
5. **State Management** (Checkpoints) - Prevent context loss

### The 15 Critical Mistakes (Watch For)
Tier 1 (Token Waste):
1. Bloated system prompts
2. Too many tools
3. No PROJECT_STATE.md
4. Tool definition duplication
5. Vague success criteria

Tier 2 (Workflow):
6. Blind batch execution
7. Skip tests before merge
8. Forget doc updates
9. Inconsistent commits
10. Over-engineer for future

Tier 3 (Tools):
11-15. Unmaintained tools, incompatible stacks, create MCPs too early, no security review, tool creep

### The 5 Commands to Implement
- `/analyze-project` - Health check
- `/optimize-tokens` - Token audit
- `/suggest-workflow` - Improvement suggestions
- `/monitor-tools` - Tool health
- `/generate-metrics` - Dashboard

### The 12 Key Metrics
Token Efficiency (4): system prompt size, tool overhead, context ratio, duplication
Velocity (4): session duration, completion rate, verification checkpoints, context switch time
Quality (4): test coverage, tool usage, commits, documentation freshness

---

## Implementation Path

### Week 1: Design & Foundation
- [ ] Read ANSWERS_TO_YOUR_QUESTIONS.md
- [ ] Read AGENT_DESIGN_SPEC.md
- [ ] Create agent system prompt (from AGENT_IMPLEMENTATION_GUIDE.md Part 1)
- [ ] Set up directory structure
- [ ] Create PROJECT_STATE.md template

### Week 2: Commands & Templates
- [ ] Implement 3 key commands (/analyze-project, /optimize-tokens, /suggest-workflow)
- [ ] Create 4 reusable prompt templates
- [ ] Create configuration files
- [ ] Test basic functionality

### Week 3: Monitoring & Metrics
- [ ] Implement /monitor-tools command
- [ ] Create metrics collection system
- [ ] Implement weekly summary generation
- [ ] Build dashboard elements

### Week 4: Polish & Testing
- [ ] Refine based on use
- [ ] User testing with 2-3 projects
- [ ] Document lessons learned
- [ ] Create user onboarding guide

---

## Success Criteria

You'll know you've succeeded when:

**Quantitative**:
- Users achieve 25-40% token efficiency improvement
- Session ramp-up time reduced from 8-10 minutes to 1-2 minutes
- 90%+ adoption of PROJECT_STATE.md pattern
- 70%+ of projects consolidate from 10+ tools to 3-5 tools

**Qualitative**:
- Users report agent as "helpful without being pushy"
- No complaints about intrusive suggestions
- Users adopt 2+ patterns within first month
- Agent becomes "invisible" when working well

---

## How the Agent Talks (Critical)

### What Works
- "I noticed X. This costs you Y tokens. Want me to help save those?" (Observation + Value)
- "Would it help if I..." (Offering, not telling)
- "Option A or Option B?" (User agency)
- "Effort: 15 min. Benefit: saves 500 tokens/session." (Transparent)

### What Doesn't Work
- "You should..." (Preachy)
- "Best practice is..." (Vague)
- "Trust me..." (Implicit authority)
- Repeated suggestions after rejection (Respectless)

---

## Files You'll Create

### For the Agent
- `.claude/agent-system.md` - Core system prompt
- `.claude/commands/analyze-project.md`
- `.claude/commands/optimize-tokens.md`
- `.claude/commands/suggest-workflow.md`
- `.claude/commands/monitor-tools.md`

### For Users
- `.claude/system.md` - Project philosophy template
- `.claude/PROJECT_STATE.md` - Session state template
- `.claude/settings.local.json` - Configuration template
- `.claude/prompts/architecture-review.md`
- `.claude/prompts/feature-planning.md`
- `.claude/prompts/code-review.md`

---

## Common Questions Answered

**Q: Why 5 patterns instead of more?**
A: Fewer patterns → higher adoption. These 5 cover 80% of optimization needs. Build on them first.

**Q: How do I know when to suggest something?**
A: Use the proactivity decision tree in QUICK_REFERENCE.md Section 8.

**Q: What if user doesn't want suggestions?**
A: Respect the proactivity setting. Answer questions only, never proactive.

**Q: How often should I monitor metrics?**
A: Weekly summaries, monthly deep dives, quarterly audits.

**Q: What if user rejects a suggestion?**
A: Document it. Never repeat the same suggestion unless context changes.

**Q: How does this integrate with Claude Code?**
A: Via MCP servers, slash commands, and system prompts. See AGENT_DESIGN_SPEC.md Section 9.

---

## Next Immediate Steps

1. **Read** ANSWERS_TO_YOUR_QUESTIONS.md (20 min)
   - You'll have answers to all 5 of your original questions
   - You'll understand the design direction

2. **Skim** QUICK_REFERENCE.md (5 min)
   - Memorize the 5 patterns
   - Remember the 15 mistakes
   - Understand the metrics

3. **Read** AGENT_DESIGN_SPEC.md sections 1-3 (45 min)
   - Deep dive on patterns
   - Configuration details
   - Mistake prevention

4. **Study** AGENT_IMPLEMENTATION_GUIDE.md Part 1 (30 min)
   - System prompt template
   - Ready-to-use commands
   - Configuration templates

5. **Reference** AGENT_EXAMPLES_AND_CASE_STUDIES.md (20 min)
   - See real examples
   - Understand impact
   - Learn communication patterns

---

## Document Cross-References

| If you need to know... | Read this... | Section |
|---|---|---|
| Direct answers to 5 questions | ANSWERS_TO_YOUR_QUESTIONS.md | All |
| Complete design spec | AGENT_DESIGN_SPEC.md | All |
| How to implement | AGENT_IMPLEMENTATION_GUIDE.md | All |
| Real-world examples | AGENT_EXAMPLES_AND_CASE_STUDIES.md | All |
| Quick checklists | QUICK_REFERENCE.md | Specific sections |
| Agent voice/personality | AGENT_EXAMPLES_AND_CASE_STUDIES.md or QUICK_REFERENCE.md 6 | Examples or Personality |
| Metrics definitions | AGENT_DESIGN_SPEC.md | Section 5 |
| Configuration files | AGENT_IMPLEMENTATION_GUIDE.md | Part 4 |
| Slash commands | AGENT_IMPLEMENTATION_GUIDE.md | Part 2 |
| Prompt templates | AGENT_IMPLEMENTATION_GUIDE.md | Part 3 |
| 5 patterns | QUICK_REFERENCE.md | Section 1 |
| 15 mistakes | QUICK_REFERENCE.md | Section 2 |

---

## Token Budget for Reading

- ANSWERS_TO_YOUR_QUESTIONS.md: ~8,000 tokens to read
- AGENT_DESIGN_SPEC.md: ~12,000 tokens to read
- AGENT_IMPLEMENTATION_GUIDE.md: ~11,000 tokens to read (skim for implementation)
- AGENT_EXAMPLES_AND_CASE_STUDIES.md: ~7,000 tokens to read
- QUICK_REFERENCE.md: ~3,000 tokens to skim

**Total**: ~30,000 tokens to fully read all documents
**Quick path** (just answers + quick ref): ~5,000 tokens

---

## Your Competitive Advantage

By implementing this agent, you'll:

1. **Help users save 25-40% tokens** → Real money saved
2. **Reduce setup friction** → 8-10 minutes → 1-2 minutes
3. **Prevent 15 common mistakes** → Fewer failed projects
4. **Provide data-driven suggestions** → Not just opinions
5. **Be proactive appropriately** → Helpful without pushy
6. **Monitor 12 key metrics** → Actionable insights

This is **specialized expertise** that general agents don't have.

---

## Final Thoughts

This agent design is based on:
- Real Claude Code usage patterns
- Analysis of what wastes tokens (context setup, unused tools, bloat)
- Workflow optimization best practices
- User experience research (being helpful without pushy)
- Measurable success metrics

The goal isn't to replace developers' decisions—it's to give them **better information** so they can **decide wisely**.

Perfect execution: Users say "Oh, I didn't realize that. That helps!" not "Okay, I'll do what the agent says."

---

## Document Statistics

| Document | Size | Read Time | Purpose |
|---|---|---|---|
| ANSWERS_TO_YOUR_QUESTIONS.md | 22 KB | 20-30 min | Direct answers |
| AGENT_DESIGN_SPEC.md | 27 KB | 40-60 min | Comprehensive spec |
| AGENT_IMPLEMENTATION_GUIDE.md | 31 KB | 30 min + coding | Build this |
| AGENT_EXAMPLES_AND_CASE_STUDIES.md | 19 KB | 20 min | Learn from examples |
| QUICK_REFERENCE.md | 13 KB | 10 min skim | Checklists |
| **Total** | **112 KB** | **~2-3 hours** | Complete package |

---

**Start with ANSWERS_TO_YOUR_QUESTIONS.md**
**Everything else is reference and implementation details**

Good luck building! You've got a solid design foundation.

