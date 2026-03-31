# Direct Answers to Your Questions

This document answers your 5 specific questions with concrete, actionable recommendations.

---

## Question 1: What are the most important workflow optimization patterns for Claude Code users?

### Answer: 5 Critical Patterns

#### Pattern 1: Context Staging via PROJECT_STATE.md
**What it is**: A single file that captures session state, decisions, blockers, and next steps.

**Why it matters**:
- Eliminates 3,000-5,000 tokens of context re-explanation per new session
- Reduces session startup time from 8-10 minutes to 1-2 minutes
- Creates accountability and project clarity
- Enables multi-person handoff

**Implementation**:
- Create `.claude/PROJECT_STATE.md` with template in AGENT_IMPLEMENTATION_GUIDE.md
- Update it at end of each session (2-3 minutes)
- Load it at start of new session

**Token Savings**: 3,000-5,000 tokens per new session

---

#### Pattern 2: Selective Tool Loading (Core + Project Pattern)
**What it is**: Load only 3-5 essential tools always, add project-specific tools when needed.

**Why it matters**:
- Each tool definition loaded costs 200-600 tokens
- 14 tools = 3,500+ tokens of pure overhead
- Startup time directly correlates to tool count
- Unused tools are cognitive overhead (decision fatigue on which tool to use)

**Implementation**:
- Core tools (always): File System, GitHub, Memory Bank
- Project tools (per-project): Domain-specific MCPs
- Temporary tools (per-task): One-off integrations
- Run `/monitor-tools` monthly to remove unused ones

**Token Savings**: 1,000-3,000 tokens per conversation

---

#### Pattern 3: Prompt Hygiene (Philosophy vs. Instructions)
**What it is**: Separate what the agent should KNOW (philosophy) from what it should DO (instructions).

**Why it matters**:
- 60%+ of typical system prompts are instruction duplication
- Tools already describe how to use them (tool descriptions)
- Philosophy (goals, constraints, patterns) needs only ~2KB
- Every KB of system prompt costs ~250 tokens per conversation

**Implementation**:
- System prompt: 2-3 KB max (project philosophy)
- Tool descriptions: How to use each tool (let tools describe themselves)
- Code/tests: The actual instructions (code is documentation)
- Documentation files: Tech stack, architecture, decisions

**Token Savings**: 1,000-2,000 tokens per conversation

---

#### Pattern 4: Incremental Task Decomposition
**What it is**: Break requests into 3 categories: Core, Polish, Future. Implement core, verify, iterate.

**Why it matters**:
- Reduces context loss (no need to re-explain entire requirements)
- Enables verification checkpoints
- Prevents over-engineering (build for current need, not hypothetical future)
- Creates natural stopping points

**Implementation**:
- When requesting feature: "I need X. Must-have: A, B, C. Nice-to-have: D, E. Future: F, G."
- Agent implements core first
- Verify it works
- Ask for polish improvements
- Saves time AND produces better results

**Token Savings**: 1,000-3,000 tokens per large feature (reduced back-and-forth)

---

#### Pattern 5: Conversation State Management
**What it is**: At key checkpoints, save intermediate state (code changes, decisions, next steps).

**Why it matters**:
- If conversation gets long/complex, state can be lost
- Token limit boundaries require state capture
- Makes transition to next conversation seamless
- Prevents "what were we doing?" syndrome

**Implementation**:
- Every 30-45 minutes: "Let me summarize where we are..."
- After major decision: "Decision made: [X chosen over Y, because Z]"
- Before code review: "Here's what changed: [file list + summary]"
- When switching tasks: "Pausing [task A], moving to [task B]. Will return to A when [condition]"

**Token Savings**: 500-2,000 tokens by preventing context re-explanation

---

### Summary for Pattern-Based Optimization
These 5 patterns stack:
- Each pattern saves 500-3,000 tokens
- Combined, they achieve 30-50% total token efficiency improvement
- Implementation time: 2-3 hours total setup across project
- ROI: Break-even after 20-50 conversations

---

## Question 2: How should configs be organized for maximum efficiency?

### Answer: Hierarchical Organization with Clear Purposes

#### Directory Structure (Best Practice)
```
.claude/
├── system.md                    # 2-3 KB: Philosophy only
├── PROJECT_STATE.md             # 2-5 KB: Session state (updated each session)
├── commands/                    # Reusable slash commands
│   ├── analyze-project.md
│   ├── setup.md
│   └── deploy.md
├── prompts/                     # Reusable prompt templates
│   ├── architecture-review.md
│   ├── feature-planning.md
│   ├── code-review.md
│   └── performance-audit.md
├── .mcprc                       # MCP server config (if multiple)
└── settings.local.json          # Permissions + tool configs
```

#### File Size Guidelines
- `system.md`: 2-3 KB (target), never > 5 KB
- `PROJECT_STATE.md`: 2-5 KB (grows with session)
- Individual prompt templates: 0.5-1.5 KB each
- `settings.local.json`: < 1 KB

**Why this matters**: Larger files = more tokens, slower loading, less mental clarity.

#### Content Organization Rules

**Rule 1: One Purpose Per File**
- Don't mix philosophy + instructions + tech stack in one file
- Each file should answer one question clearly

**Rule 2: Reuse Over Repetition**
- If something is described once clearly (e.g., tool descriptions), don't repeat it
- Reference instead: "See tool description in settings.json"

**Rule 3: Time-Based Organization**
- `system.md`: Permanent (project-level, rarely changes)
- `PROJECT_STATE.md`: Session-level (updated each session)
- `prompts/`: Feature-level (reused for similar requests)
- `commands/`: Workflow-level (reused across sessions)

**Rule 4: Permissions Hierarchy**
- Allow: Essential tools only (git, file read)
- Ask: Deployment/publish commands
- Deny: Dangerous commands (force push, mass delete)

#### Configuration Priority (Implementation Order)
1. Create `system.md` (20 minutes)
2. Create `PROJECT_STATE.md` template (5 minutes)
3. Create 2-3 most-used `commands/` (30 minutes)
4. Create `prompts/` directory with 3 templates (30 minutes)
5. Audit and trim `settings.local.json` (10 minutes)

**Total setup time**: ~95 minutes per project

**Return**: 3-5 years of maintainability improvements

---

## Question 3: What common mistakes should this agent help users avoid?

### Answer: 15 Critical Mistakes (Ranked by Impact)

#### Tier 1: Token Waste Mistakes (Huge Impact)

**Mistake #1: Bloated System Prompts (5,000+ tokens wasted)**
- Problem: 8-12 KB system prompts with verbose instructions
- Why: "Better to be explicit" thinking, fear of ambiguity
- Agent Action: Suggest trimming, offer consolidation help
- Prevention: "System prompts should be philosophy, not manual"
- Fix: Move content to README, docs, tool descriptions

**Mistake #2: Loading All Available Tools (2,000-5,000 tokens wasted)**
- Problem: 12+ MCPs enabled, most rarely used
- Why: "Might need it later" thinking
- Agent Action: Profile tool usage, identify and remove unused
- Prevention: Load only 3-5 core tools, add others per-project
- Fix: Edit settings.json, test startup, verify no functionality loss

**Mistake #3: Skipping PROJECT_STATE.md Updates (3,000-5,000 tokens wasted per new session)**
- Problem: Starting fresh each time, re-explaining context
- Why: "I'll remember" thinking, no established ritual
- Agent Action: Prompt for state updates at session end
- Prevention: Make state updates part of closing ritual
- Fix: Create template, spend 2 minutes updating at end

**Mistake #4: Tool Definition Duplication (1,000+ tokens wasted)**
- Problem: Same information in system prompt AND tool description
- Why: Belt-and-suspenders thinking
- Agent Action: Detect and consolidate duplication
- Prevention: Rely on tool descriptions, reference in system prompt
- Fix: Delete redundant sections from system.md

**Mistake #5: Vague Success Criteria (500-1,500 tokens in misdirection)**
- Problem: "Make this better" or "Add functionality" without specifics
- Why: Assuming shared understanding
- Agent Action: Ask clarifying questions before working
- Prevention: Always specify: metric, target, constraints
- Fix: "By better you mean X? Measured how? Current vs target?"

---

#### Tier 2: Workflow Mistakes (Medium-High Impact)

**Mistake #6: Blind Batch Execution (500-3,000 tokens + time wasted)**
- Problem: "Run all these commands without checking between"
- Why: Speed bias, fear of over-communication
- Agent Action: Suggest chunking into stages with verification
- Prevention: Execute, verify, execute, verify
- Fix: Break request into 3-step chunks with checkpoints

**Mistake #7: Inadequate Test Coverage Before Merging (1,000-2,000 tokens + broken builds)**
- Problem: Pushing changes without running full test suite
- Why: Confidence bias, "tests probably pass"
- Agent Action: Ask test status before code review
- Prevention: Always verify tests pass before merge discussion
- Fix: "What's the test coverage? Let me remind you to verify."

**Mistake #8: Forgetting to Update Documentation (500-1,000 tokens future cost)**
- Problem: Code changes without updating architecture docs
- Why: Documentation feels separate from code
- Agent Action: Remind when suggesting code changes
- Prevention: Treat docs as first-class (update with code)
- Fix: When suggesting changes, include doc updates in scope

**Mistake #9: Inconsistent Commit Messages (Future debugging cost)**
- Problem: Mix of "fix bug", "wip", "asdf", conventional commits
- Why: No clear standard established
- Agent Action: Suggest commit message improvements
- Prevention: Enforce conventional commits via pre-commit hook
- Fix: Create .git/hooks/commit-msg to validate format

**Mistake #10: Over-Engineering for Future (2-5 hours wasted)**
- Problem: Building "flexible" solutions for hypothetical use cases
- Why: Experience bias (preparing for problems faced in past)
- Agent Action: Challenge over-generalization in design
- Prevention: Build for current requirements + 1 reasonable extension
- Fix: "What integrations will you DEFINITELY use in next 6 months?"

---

#### Tier 3: MCP/Tool Mistakes (Medium Impact)

**Mistake #11: Installing Unmaintained Tools (ongoing security risk)**
- Problem: Adding MCPs with last update > 1 year ago
- Why: No maintenance status check
- Agent Action: Scan installed tools for staleness
- Prevention: Check maintenance status before install
- Fix: Create tool audit process, run quarterly

**Mistake #12: Incompatible Tool Stacks (build failures)**
- Problem: Two MCPs requiring conflicting versions (Node 16 vs 18)
- Why: No compatibility checking
- Agent Action: Detect and flag conflicts
- Prevention: Verify compatibility before combining
- Fix: Check README for version requirements, test together

**Mistake #13: Creating MCPs Too Early (5-10 hours wasted)**
- Problem: Wrapping a tool as MCP on first use
- Why: Desire for integration, underestimating setup cost
- Agent Action: Suggest "when to custom MCP" threshold
- Prevention: Use tool directly until needed 3+ times
- Fix: "Is this a daily task? Will you do this in 2+ projects?"

**Mistake #14: No Security Review Before Tool Install (potential vulnerability)**
- Problem: Installing plugins without checking code
- Why: Trust assumption, "community would flag issues"
- Agent Action: Ask for security review confirmation
- Prevention: Read plugin source, verify author, check permissions
- Fix: "Have you reviewed the source code for [plugin]?"

**Mistake #15: Plugin Creep (bloated context, startup lag)**
- Problem: Accumulating tools that duplicate functionality
- Why: No periodic audit
- Agent Action: Suggest consolidation opportunities
- Prevention: Audit tools quarterly, remove redundant ones
- Fix: "Do you need both X and Y? They seem to overlap."

---

### How Agent Prevents These

**For Mistakes #1-5** (Token waste): Run `/optimize-tokens` command
**For Mistakes #6-10** (Workflow): Use `/suggest-workflow` and code review process
**For Mistakes #11-15** (Tools): Run `/monitor-tools` monthly

---

## Question 4: How can we make the agent proactive without being intrusive?

### Answer: Consent-Based Proactivity with Clear Value Props

#### Proactivity Principle: Ask Permission, Not Forgiveness

**Rule 1: Always explain the value first**
- Good: "I noticed X. This costs you Y tokens. Want me to help you save those?"
- Bad: "You should probably fix X"

**Rule 2: Offer to help or skip**
- Good: "Want me to set that up? (5 min effort) Or skip for now?"
- Bad: "I'm going to optimize this for you"

**Rule 3: Timing matters - suggest at natural checkpoints**
- Good checkpoints: End of session, task completion, blocker resolution
- Bad checkpoints: Mid-flow, during debugging, during deep focus

#### Opt-In Proactivity Levels

Recommend users configure in `settings.local.json`:

```json
{
  "proactivityLevel": "balanced",
  "preferences": {
    "suggest_optimizations": true,
    "flag_token_waste": true,
    "remind_test_runs": true,
    "prompt_state_updates": true,
    "daily_health_checks": false
  }
}
```

**Silent**: Only answer direct questions
**Minimal**: Suggest optimizations only if directly asked
**Balanced** (default): Gentle guidance + end-of-session recaps
**Aggressive**: Frequent suggestions + daily checks

#### Specific Proactive Patterns (Non-Intrusive)

**Pattern A: Diagnostic Checkups (Optional, Clearly Explained)**
```
Agent: "I can run a 2-minute project health check if you'd like:
1. Compare current state vs last session's PROJECT_STATE.md
2. Flag any stale tools or obvious optimizations
3. Suggest 1-2 quick wins

Want me to run it? (Y/n)"
```
Non-intrusive: Optional, time-bounded, explicit value

**Pattern B: Gentle Guidance (Framed as Options)**
```
Agent: "I noticed your system prompt is 7KB. Trimming it to ~3KB
would save ~1,500 tokens/conversation.

Would it help if I:
A) Showed you the parts that could move to other files?
B) Just did the refactoring and you review it?
C) Skipped this for now?

Your call."
```
Non-intrusive: Multiple options, explicit benefit, user chooses

**Pattern C: End-of-Session Recap (Quick Summary)**
```
Agent: "Looking like we're wrapping up! Quick recap:
- Completed: [what we did]
- Next: [what's next]
- Blockers: [any issues]

Want me to update PROJECT_STATE.md? Or just close out?"
```
Non-intrusive: Summary, not demand; user decides

**Pattern D: Anomaly Detection (Observation + Offer)**
```
Agent: "I see you've run tests 8 times this session.
That's actually great - means you're being thorough.
Just noting: if we set up a pre-commit hook to run tests automatically,
you could save ~3 min per session. Want to try?"
```
Non-intrusive: Observation-based, positive framing, offer to help

**Pattern E: Learning Moment (Opportunistic Teaching)**
```
Agent: "Since you're learning this pattern, want me to:
- Explain why we chose X over Y?
- Show you an example from production code?
- Create a template you can reuse?"
```
Non-intrusive: Only offers if user seems interested, educational

#### When NOT to Suggest (Critical)

**Never interrupt during**:
- Active coding/typing (user in flow)
- Problem-solving/debugging (user focused)
- Explicit focus work ("just do X")
- User is clearly stressed/frustrated (wrong moment)

**Always respect**:
- User's proactivity preference setting
- Explicit instruction ("don't suggest fixes")
- Silent mode settings
- User's focus signals

#### Building Trust Through Transparency

Every suggestion should include:
1. **Why** (data-driven reason)
2. **What** (specific action)
3. **Cost** (effort required)
4. **Benefit** (what you gain)
5. **Choice** (user decides)

Example:
```
"Your PROJECT_STATE.md is 4 days old. Keeping it fresh means new sessions
start with full context instead of requiring 5 minutes of explanation.

Want me to update it? (Takes 2 minutes, saves 3+ minutes next session)
Or skip for now?"
```

---

## Question 5: What metrics or indicators should it monitor for optimization opportunities?

### Answer: 8 Key Metrics + Thresholds

#### Tier 1: Token Efficiency Metrics (Most Important)

**Metric 1: System Prompt Size**
- Measurement: Bytes in .claude/system.md
- Target: < 3 KB (contains philosophy only)
- Yellow flag: 3-5 KB (getting large)
- Red flag: > 5 KB (needs trimming)
- Action: Suggest refactoring into separate files

**Metric 2: Tool Definition Overhead**
- Measurement: Count of enabled MCP servers + skills
- Target: 3-5 active tools
- Yellow flag: 6-8 tools (getting heavy)
- Red flag: > 10 tools (bloat)
- Action: Profile usage, remove < 1% used tools

**Metric 3: Context Setup Ratio**
- Measurement: (Tokens explaining state) / (Total conversation tokens)
- Target: < 10% (minimal context setup needed)
- Yellow flag: 10-15% (some waste)
- Red flag: > 20% (major waste)
- Action: Implement/improve PROJECT_STATE.md

**Metric 4: Prompt Duplication Index**
- Measurement: % of system prompt content also in tool descriptions
- Target: 0% (no duplication)
- Yellow flag: 5-10% (some overlap)
- Red flag: > 10% (significant duplication)
- Action: Consolidate duplicated content

---

#### Tier 2: Development Velocity Metrics

**Metric 5: Session Duration**
- Measurement: Time from session start to end
- Target: 45-90 minutes (healthy focus window)
- Yellow flag: 90-120 minutes (long but acceptable)
- Red flag: > 2 hours (burnout/focus drift risk)
- Action: Suggest breaks, task chunking

**Metric 6: Task Completion Rate**
- Measurement: (Completed tasks) / (Started tasks)
- Target: > 80% (most started tasks finished)
- Yellow flag: 60-80% (okay, but improvement possible)
- Red flag: < 60% (tasks too ambitious or unclear)
- Action: Suggest breaking into smaller chunks

**Metric 7: Verification Checkpoint Frequency**
- Measurement: Count of "test passed" / "build succeeded" / "verify result" messages
- Target: Minimum 1 per task
- Yellow flag: < 1 per task (might miss issues)
- Red flag: None in session (risky)
- Action: Remind about test/build verification

**Metric 8: Context Switch Time**
- Measurement: Time since last PROJECT_STATE.md update
- Target: Updated at end of each session (within 30 min)
- Yellow flag: > 30 minutes without update
- Red flag: > 1 hour without update (context loss risk)
- Action: Prompt for state update, summarize session

---

#### Tier 3: Code Quality Metrics

**Metric 9: Test Coverage Trend**
- Measurement: Coverage % tracked session-to-session
- Target: Increasing or stable
- Yellow flag: Flat (not improving)
- Red flag: Decreasing (quality degradation)
- Action: Ask about intentional coverage changes, suggest focus areas

**Metric 10: Tool Usage Distribution**
- Measurement: Invocations per tool per session
- Target: Expected distribution (core tools: 5+, specialized: 1-3, unused: 0)
- Yellow flag: Unused tool detected (remove?)
- Red flag: Tool installed but never invoked after 5 sessions
- Action: Recommend removal or clarify purpose

**Metric 11: Commit Message Quality**
- Measurement: % following conventional commit format
- Target: 95%+ (consistent format)
- Yellow flag: 80-95% (mostly compliant)
- Red flag: < 80% (needs standard)
- Action: Suggest commit message template, pre-commit hook

**Metric 12: Documentation Freshness**
- Measurement: Days since architecture docs last updated
- Target: Updated when code changes
- Yellow flag: > 1 week stale
- Red flag: > 2 weeks stale
- Action: Remind to update docs with code changes

---

### How to Aggregate These Metrics

#### Weekly Summary (Recommended Frequency)
```
Project Health: [Green/Yellow/Red overall status]

Token Efficiency:
- System prompt: 3.2 KB (Good)
- Tools: 4 active (Good)
- Context setup: 8% of tokens (Good)

Velocity:
- Tasks completed: 8 of 10 (80%)
- Avg session: 58 minutes (Good)
- Verification checkpoints: 1 per task (Good)

Quality:
- Test coverage: 74% (trending up)
- Documentation: 2 days stale
- Commit format: 100% conventional

Tools:
- All maintained (< 6 months old)
- Usage healthy
- No conflicts

Top 3 Priorities Next Week:
1. [What to focus on]
2. [What to focus on]
3. [What to focus on]
```

#### When to Alert (Red Flags)
1. System prompt > 5 KB (suggest trimming)
2. > 8 active tools (recommend removal)
3. Context setup > 20% (implement PROJECT_STATE.md)
4. Task completion < 60% (suggest smaller chunks)
5. Test coverage decreasing (ask about intentional changes)
6. Documentation > 2 weeks stale (reminder)
7. Session duration > 2 hours consistently (watch for burnout)

#### Dashboard Elements
- Token efficiency trend (7-day rolling average)
- Task completion velocity (7-day rolling)
- Test coverage trend line
- Tool health color-coded (green/yellow/red)
- Days-to-deadline for stale metrics

---

### Implementation Recommendation

**Phase 1 (Immediate)**: Track 5 critical metrics
1. System prompt size
2. Tool count
3. Context setup ratio
4. Task completion rate
5. Verification checkpoints

**Phase 2 (Week 2-3)**: Add 5 supporting metrics
6. Session duration
7. Test coverage trend
8. Documentation freshness
9. Commit message quality
10. Tool staleness

**Phase 3 (Month 2)**: Advanced metrics
11. Tool usage distribution
12. Context switch time
13. Proactivity impact
14. Token savings realized
15. User satisfaction

---

## Summary: The Big Picture

Your agent should:

1. **Advise on patterns**: Focus on the 5 core patterns (Context Staging, Selective Tools, Prompt Hygiene, Task Decomposition, State Management)

2. **Organize configs**: Hierarchical structure with clear purposes, files sized for efficiency

3. **Prevent mistakes**: Proactively surface the 15 critical mistakes via analysis commands

4. **Be proactive appropriately**: Suggest improvements with clear value props, respect user preferences, never pushy

5. **Monitor metrics**: Track 12+ indicators, alert on red flags, provide weekly summaries

The agent succeeds when users achieve **30-50% improvement in token efficiency** while reducing **development friction by 40%+**.

---

**Implementation Timeline**:
- Week 1: Agent design + system prompt
- Week 2-3: Core commands + templates
- Week 4+: Metrics dashboard + refinement

**Success Threshold**: Users adopt 3+ patterns within first month, report "helpful without pushy" satisfaction.

