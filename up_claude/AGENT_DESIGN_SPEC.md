# Claude Code Workflow Optimization Agent - Design Specification

**Agent Purpose**: Specialized advisor that helps Claude Code users optimize their workflows, projects, and token efficiency.

**Target Users**: Claude Code Pro/Max/Team users (engineers, developers, AI builders)

---

## 1. Most Important Workflow Optimization Patterns

### 1.1 Token Efficiency Architecture

The agent should help users understand that Claude Code's token budget is a **first-class constraint**, not a secondary consideration.

#### Key Patterns to Advise:

**Pattern A: Context Staging**
- Users should maintain a `.claude/PROJECT_STATE.md` file (updated after each session)
- This file serves as a "session resume" - new Claude Code instances load it first
- Contains: recent decisions, current blockers, completed work, architecture decisions
- Dramatically reduces time explaining state on context switches
- Typical savings: 2,000-5,000 tokens per new session

**Pattern B: Prompt Hygiene**
- System prompts should be split: generic (.claude/system.md) vs project-specific (.claude/PROJECT_SYSTEM.md)
- Generic system prompts should focus on philosophy, not instruction - let tools do the work
- Avoid duplication: if instructions exist in tool descriptions, don't repeat in system prompt
- Token savings: 500-1,500 tokens typically wasted on repetition

**Pattern C: Selective Tool Loading**
- Not all MCP servers/skills should be loaded by default
- Tools consume tokens in context even when unused (tool definitions + descriptions)
- Recommended: 3-5 core tools always loaded, others loaded per-project or per-session
- Profile tool usage: if a tool hasn't been invoked in 3+ sessions, consider removing
- Token savings: 1,000-3,000 tokens per unused tool definition

**Pattern D: Smart File Organization**
```
.claude/
  ├── system.md                 # Generic system instructions (reusable)
  ├── PROJECT_STATE.md         # Current project state (updated per session)
  ├── commands/                 # Slash commands (only load relevant ones)
  ├── prompts/                  # Reusable prompt templates
  │   ├── code-review.md
  │   ├── architecture.md
  │   └── testing.md
  └── settings.local.json       # Permissions, tool configs
```
- Each file should have clear purpose (no "kitchen sink" files)
- Encourages reuse across projects

**Pattern E: Conversation State Management**
- Start conversations with: "Load project context from /path/to/PROJECT_STATE.md"
- Saves 3,000+ tokens of manual explanation
- End conversations with: "Update PROJECT_STATE.md with today's progress"
- Creates accountability and reduces onboarding time

### 1.2 Development Workflow Patterns

#### Pattern A: The "Query-Execute-Verify" Loop
Best practice workflow for reliable execution:
1. **Query**: Ask agent to analyze current state (`git status`, file structure)
2. **Execute**: Run changes (tests, builds, deployments)
3. **Verify**: Confirm expected outcomes (test passes, file changes correct)

Mistakes to avoid:
- Blind batch execution without intermediate verification
- Running multiple unrelated commands sequentially without checking each
- Skipping test runs before deployment

#### Pattern B: Proactive Skill Composition
Instead of asking for individual features, structure requests to enable stacking:
```
"I need to add TypeScript support to my Node project.
Can you:
1. Add tsconfig.json with strict mode
2. Create a build script in package.json
3. Set up src/ and dist/ directories
4. Update .gitignore appropriately"
```
This enables:
- Fewer token-expensive back-and-forths
- Consistent project state after completion
- Natural verification points

#### Pattern C: Incremental Problem Solving
For complex features, break into 3 categories:
1. **Core** - Must have for basic functionality
2. **Polish** - Nice-to-have improvements
3. **Future** - Can be deferred

Ask the agent to implement core first, verify it works, then iterate on polish.

### 1.3 Plugin/MCP Integration Patterns

#### Pattern A: The "Core + Project" Plugin Strategy
- **Core plugins** (loaded always): File System, GitHub, Memory Bank - 3 essential tools
- **Project plugins** (loaded per-project): domain-specific MCPs
- **Temporary plugins** (loaded for specific task): one-off tools

Benefit: 40% faster startup, cleaner context, easier troubleshooting

#### Pattern B: Tool Compatibility Verification
Before recommending a tool, check:
1. License compatibility with project
2. Maintenance status (last update < 6 months)
3. Dependency conflicts (e.g., two Node tools with incompatible Node versions)
4. Community adoption (Reddit mentions, GitHub stars)

#### Pattern C: Custom MCP Threshold
Create custom MCP servers when:
- Existing tools don't cover >70% of use case
- Same integration needed across 3+ projects
- Integration requires frequent updates (changes daily/weekly)

Don't create custom MCP when:
- Wrapping a rarely-used API
- Single project usage
- Existing MCP covers 80%+ of needs

---

## 2. Configuration Organization for Maximum Efficiency

### 2.1 File Structure Hierarchy

```
project-root/
├── .claude/                          # Claude Code specific configs
│   ├── system.md                     # Project system prompt (project-wide, ~2-3KB)
│   ├── PROJECT_STATE.md              # Session state tracker (updated EOD)
│   ├── commands/
│   │   ├── setup.md                  # /setup command
│   │   ├── test.md                   # /test command
│   │   ├── deploy.md                 # /deploy command
│   │   └── review.md                 # Code review workflow
│   ├── prompts/                      # Reusable prompt templates
│   │   ├── architecture-review.md    # For design decisions
│   │   ├── performance-audit.md      # For optimization work
│   │   └── security-check.md         # For security reviews
│   ├── .mcprc                        # MCP server configuration (if using multiple)
│   └── settings.local.json           # Permissions and local settings
├── .gitignore
├── README.md
└── [project files...]
```

### 2.2 Content Guidelines by File Type

#### `system.md` - Project System Prompt
**Size**: 1-3 KB max
**Content**:
- Project goals and philosophy (2-3 paragraphs)
- Tech stack overview
- Architecture decisions (link to detailed docs if needed)
- Common patterns and conventions
- DO NOT INCLUDE: Step-by-step instructions, tutorials, or how-to guides

**Template**:
```markdown
# Project System Prompt

## Project Context
[1-2 sentence description]

## Tech Stack
- Language: Python 3.11+
- Framework: FastAPI
- Database: PostgreSQL
- Deployment: Docker + K8s

## Key Architectural Patterns
- Service-oriented architecture
- Event-driven for async operations
- See ARCHITECTURE.md for detailed design

## Team Conventions
- Code style: Black formatter
- Git: Conventional commits
- PR: Require 1 approval + all tests passing

## Decision Log
See decisions/ directory for ADRs (Architecture Decision Records)
```

#### `PROJECT_STATE.md` - Session State
**Size**: 2-5 KB
**Updated**: End of each Claude Code session
**Content**:
- Current task/goal
- Recent decisions made
- Known blockers
- Files modified today
- Next steps for next session
- Test status

**Template**:
```markdown
# Project State - Session [DATE]

## Current Goal
[What are we working on?]

## Progress This Session
- [ ] Item 1 completed
- [ ] Item 2 completed
- [ ] Known issue: [description]

## Key Decisions Made
- Decision 1: Why we chose X over Y

## Blockers
- Blocker 1: Description and proposed solution

## Files Modified
- src/main.py
- tests/test_feature.py

## Test Status
- All tests passing: Yes/No
- Coverage: [XX]%

## Next Session Priorities
1. [Priority 1]
2. [Priority 2]
3. [Priority 3]

## Architecture Notes
[Any new patterns introduced today]
```

#### `commands/` - Slash Commands
**Size**: 0.5-2 KB per command
**Purpose**: Automate common tasks
**Good Candidates**:
- Setup/initialization
- Testing/validation
- Deployment
- Code review workflows
- Documentation generation

**Bad Candidates**:
- One-time manual tasks
- Simple file operations (use native tools instead)
- Commands that need heavy user interaction

#### `prompts/` - Reusable Prompt Templates
**Size**: 1-3 KB per prompt
**Purpose**: Standardize request formats for common tasks
**Examples**:
- Architecture review template
- Performance audit template
- Security review template
- New feature planning template

### 2.3 Settings.local.json Structure

```json
{
  "permissions": {
    "allow": [
      "WebSearch",
      "Bash(git add:*)",
      "Bash(npm install)",
      "Read(/path/to/sensitive/file)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force)"
    ],
    "ask": [
      "Bash(npm publish)"
    ]
  },
  "spinnerTipsEnabled": true,
  "tools": {
    "disabled": []
  }
}
```

### 2.4 Implementation Priority

1. **Week 1**: Create `.claude/system.md` and `.claude/PROJECT_STATE.md`
2. **Week 2**: Add 2-3 most-used slash commands
3. **Week 3**: Create prompt templates for common tasks
4. **Ongoing**: Update PROJECT_STATE.md after each session

---

## 3. Common Mistakes This Agent Should Help Users Avoid

### 3.1 Token Waste Mistakes

**Mistake #1: Bloated System Prompts**
- Problem: Including 10+ KB of instructions in system prompt
- Why it happens: Tendency to "document everything" upfront
- Cost: 5,000+ wasted tokens per conversation
- Solution: Keep system prompt to philosophy (2KB), use tools for details
- Agent action: Analyze system.md and suggest trimming

**Mistake #2: Loading All Available Tools**
- Problem: Enabling 15+ MCPs, all definitions loaded to context
- Why it happens: "Might need these later"
- Cost: 2,000-5,000+ tokens per conversation
- Solution: Load only 3-5 core tools, add others per-project
- Agent action: Profile tool usage, recommend removals

**Mistake #3: Skipping PROJECT_STATE.md Updates**
- Problem: Starting new session with zero context
- Why it happens: "I'll remember where we were"
- Cost: 3,000-5,000 tokens re-explaining state
- Solution: Make state file updates part of closure ritual
- Agent action: Prompt at end of session to update state file

**Mistake #4: Tool Definition Duplication**
- Problem: Tool description + system prompt both describe the same thing
- Why it happens: Belt-and-suspenders thinking
- Cost: 1,000+ wasted tokens
- Solution: Rely on tool descriptions, reference in system prompt only
- Agent action: Detect and flag duplication

**Mistake #5: Context Thrashing**
- Problem: Asking for same information multiple times in conversation
- Why it happens: Not maintaining local facts
- Cost: 500-2,000 tokens wasted
- Solution: Use `/read` to load files once, reference locally
- Agent action: Suggest caching patterns

### 3.2 Workflow Mistakes

**Mistake #6: Blind Batch Execution**
- Problem: "Run all these commands then make changes" (no verification)
- Risk: Cascading failures, hard to debug
- Solution: Execute in stages, verify each stage
- Agent action: Suggest chunking large requests

**Mistake #7: Inadequate Test Coverage Before Merging**
- Problem: Pushing changes without running full test suite
- Risk: Broken main branch, blocking other developers
- Solution: Always verify `npm test` or `pytest` passes
- Agent action: Ask about test status before code review

**Mistake #8: Forgetting to Update Documentation**
- Problem: Code changes without updating architecture docs
- Risk: Onboarding failures, team confusion
- Solution: Treat docs as first-class (update with code)
- Agent action: Remind to update docs when suggesting code changes

**Mistake #9: Inconsistent Commit Messages**
- Problem: Mix of "fix bug", "wip", "asdf", conventional commits
- Risk: Hard to parse git history, bisect fails
- Solution: Enforce conventional commits or similar
- Agent action: Suggest commit message improvements

**Mistake #10: Over-Engineering for Future**
- Problem: Building "flexible" solutions for hypothetical use cases
- Cost: 2x development time, complexity debt
- Solution: Build for current requirements + 1 reasonable extension
- Agent action: Challenge over-generalization in design

### 3.3 MCP/Plugin Mistakes

**Mistake #11: Installing Unmaintained Tools**
- Problem: Adding MCPs with last update > 1 year ago
- Risk: Incompatibility, security issues
- Solution: Check maintenance status before install
- Agent action: Scan installed tools for staleness

**Mistake #12: Incompatible Tool Stacks**
- Problem: Two MCPs requiring conflicting versions (Node 16 vs 18)
- Risk: Build failures, confusion
- Solution: Verify compatibility before combining
- Agent action: Detect and flag conflicts

**Mistake #13: Creating MCPs Too Early**
- Problem: Wrapping a tool as MCP on first use
- Cost: 5-10 hours of setup, maintenance burden
- Solution: Use tool directly until needed 3+ times
- Agent action: Suggest "when to custom MCP" threshold

**Mistake #14: No Security Review Before Tool Install**
- Problem: Installing plugins without checking code
- Risk: Supply chain attacks, data leaks
- Solution: Read plugin source, verify author, check permissions
- Agent action: Ask for security review confirmation

**Mistake #15: Plugin Creep**
- Problem: Accumulating tools that duplicate functionality
- Cost: Bloated context, startup lag, confusion
- Solution: Audit tools quarterly, remove redundant ones
- Agent action: Suggest consolidation opportunities

### 3.4 Communication Mistakes

**Mistake #16: Vague Requests**
- Problem: "Make this better" or "Add functionality"
- Impact: Agent guesses, wrong direction
- Solution: Specific requests with success criteria
- Agent action: Ask clarifying questions, suggest request templates

**Mistake #17: Not Specifying Constraints**
- Problem: "Make this faster" (3ms? 30%? under 1s?)
- Impact: Wrong solutions, wasted time
- Solution: Always include metrics, targets, constraints
- Agent action: Prompt for success criteria

**Mistake #18: Silent Assumption Stacking**
- Problem: Assuming knowledge of domain/project/context
- Impact: Agent misses important context
- Solution: Explicitly state assumptions
- Agent action: Surface and verify assumptions

---

## 4. Making the Agent Proactive Without Being Intrusive

### 4.1 Proactive Patterns (Non-Intrusive)

#### Pattern A: Diagnostic Checkups (Requested, Not Pushed)
**Trigger**: User asks any project-related question

**Behavior**:
```
When starting work on a project, I can run a quick health check:
1. Examine current state (git status, test status, file changes)
2. Compare against PROJECT_STATE.md from last session
3. Flag discrepancies or outdated information
4. Suggest 1-2 quick optimizations if obvious

Would you like me to run a project health check? (Y/n)
```

**Non-intrusive**: Optional, clearly explained, saves 2-3 minutes

#### Pattern B: Gentle Guidance (Questions, Not Commands)
**Instead of**: "You should update your system prompt"

**Better**: "I noticed your system prompt is 8KB. Would it help to trim it to focus on philosophy? I can help extract technical details to other files."

**Mechanics**:
- Frame as options, not demands
- Explain the benefit (tokens saved, clarity, etc.)
- Offer concrete help
- Let user decide

#### Pattern C: End-of-Session Recap
**Trigger**: When conversation appears to be ending (user says "thanks", "I'll continue later", etc.)

**Behavior**:
```
Before we wrap up, would you like me to:
1. Update PROJECT_STATE.md with today's progress?
2. Suggest next-session priorities?
3. Flag any lingering blockers?

(Any of the above? Or just exit?)
```

**Non-intrusive**: Quick summary, doesn't require action

#### Pattern D: Anomaly Detection
**Trigger**: Agent notices unusual patterns

**Examples**:
- "I see you've used WebSearch 8 times this session. Is there documentation we could add locally to reduce API calls?"
- "I notice 3 consecutive test failures on the same module. Want me to dig into the pattern?"
- "You've modified .claude/system.md 4 times today. Happy to consolidate these into a final version?"

**Non-intrusive**: Frame as observation + offer, not concern

### 4.2 Opt-In Proactivity Levels

Recommend users configure their preference:

```json
{
  "proactivity": "balanced",  // silent, minimal, balanced, aggressive
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
**Minimal**: Suggest optimizations only if asked
**Balanced** (default): Gentle guidance + end-of-session recaps
**Aggressive**: Frequent suggestions + daily checks

### 4.3 Proactive Moments (When to Engage)

#### Safe Moments:
1. User asks clarifying question ("What's a good pattern for X?")
2. Agent completes task (suggest verification step)
3. Conversation reaching natural checkpoint
4. User mentions they're learning (offer to explain better patterns)

#### Unsafe Moments (Don't Interrupt):
1. Deep focus work (obvious from rapid exchanges)
2. User in problem-solving flow
3. Debugging session in progress
4. User explicitly said "just do X"

### 4.4 Trust Through Transparency

All proactive suggestions should include:
1. Why this might help (metric: tokens, time, complexity)
2. What it involves (effort estimate)
3. Offer to help or skip
4. No pressure language

Example:
```
I noticed you're running tests after every small change.
If we set up a pre-commit hook to run tests automatically,
you could save ~2 minutes per cycle.

Want me to set that up? (3 min setup cost) Or skip for now?
```

---

## 5. Metrics & Indicators to Monitor for Optimization

### 5.1 Token Efficiency Metrics

#### Metric A: System Prompt Size
- **Target**: < 3 KB (philosophy only)
- **Calculation**: Bytes in system.md
- **Red Flag**: > 8 KB
- **Agent Action**: Suggest refactoring into separate files

#### Metric B: Tool Definition Overhead
- **Target**: 3-5 active tools
- **Calculation**: Count of enabled MCP servers + skills
- **Red Flag**: > 10 tools
- **Agent Action**: Profile usage, suggest removals

#### Metric C: Token Spent on Context Setup
- **Calculation**: Tokens in first message explaining state / total tokens in conversation
- **Target**: < 10% of conversation tokens
- **Red Flag**: > 20%
- **Agent Action**: Recommend PROJECT_STATE.md usage

#### Metric D: Prompt Reuse Ratio
- **Calculation**: (Repeated patterns) / (Total requests)
- **Target**: 30%+ (reusing patterns/templates)
- **Red Flag**: < 10%
- **Agent Action**: Suggest creating reusable prompts for common tasks

### 5.2 Development Velocity Metrics

#### Metric A: Session Duration
- **Target**: 45-90 minutes (healthy focus window)
- **Red Flag**: > 2 hours (burnout risk, focus drift)
- **Agent Action**: Suggest taking a break or breaking into smaller tasks

#### Metric B: Task Completion Rate
- **Calculation**: (Completed tasks) / (Attempted tasks)
- **Target**: > 80%
- **Red Flag**: < 60%
- **Agent Action**: Suggest breaking tasks into smaller chunks

#### Metric C: Verification Checkpoints
- **Calculation**: Count of "test passed" / "build succeeded" messages
- **Target**: At least 1 per task
- **Red Flag**: 0 per session
- **Agent Action**: Remind about test/build verification

#### Metric D: Context Switch Time
- **Calculation**: Time between PROJECT_STATE.md updates
- **Target**: < 30 minutes elapsed since last state update
- **Red Flag**: > 1 hour without state update
- **Agent Action**: Prompt for state update

### 5.3 Code Quality Metrics

#### Metric A: Test Coverage Trend
- **Calculation**: Track from session to session
- **Target**: Increasing or stable
- **Red Flag**: Decreasing
- **Agent Action**: Ask about intentional coverage changes

#### Metric B: Lint/Type Check Passing Rate
- **Calculation**: % of changes that pass linting
- **Target**: 95%+
- **Red Flag**: < 80%
- **Agent Action**: Suggest pre-commit hooks or better IDE setup

#### Metric C: Commit Quality
- **Calculation**: Follow conventional commit format + descriptive messages
- **Target**: 90%+
- **Red Flag**: Mix of formats
- **Agent Action**: Suggest commit message templates

#### Metric D: Documentation Freshness
- **Calculation**: Architecture docs updated with code changes
- **Target**: 100% (docs updated with code)
- **Red Flag**: Docs > 2 weeks stale
- **Agent Action**: Remind to update docs

### 5.4 Tool Health Metrics

#### Metric A: Tool Staleness
- **Calculation**: Days since last tool update (from GitHub API)
- **Target**: < 6 months
- **Red Flag**: > 1 year
- **Agent Action**: Suggest upgrade or replacement

#### Metric B: Tool Invocation Frequency
- **Calculation**: Count per tool per session
- **Target**: > 0 (tools being used) or = 0 (remove unused)
- **Red Flag**: Installed but never used
- **Agent Action**: Suggest removal or clarify purpose

#### Metric C: Tool Success Rate
- **Calculation**: (Successful invocations) / (Total invocations)
- **Target**: > 90%
- **Red Flag**: < 80%
- **Agent Action**: Diagnose failures, suggest configuration changes

#### Metric D: Tool Compatibility Status
- **Calculation**: Any dependency conflicts, version mismatches
- **Target**: 0 conflicts
- **Red Flag**: Any conflicts
- **Agent Action**: Resolve immediately or suggest alternatives

### 5.5 Reporting & Dashboards

#### Weekly Summary
```
Project: [name]
Week of: [date]

Tokens:
- Avg system prompt size: [bytes]
- Avg conversation length: [tokens]
- Context efficiency: [ratio]

Velocity:
- Tasks completed: [count]
- Avg session duration: [mins]
- Verification checkpoints: [count]

Quality:
- Test coverage: [%]
- Lint passing: [%]
- Documentation freshness: [days stale]

Tools:
- Active tools: [count]
- Unused tools: [list]
- Stale tools: [list]

Recommendations:
1. [Top priority optimization]
2. [Secondary optimization]
3. [Nice-to-have improvement]
```

#### Dashboard Elements
- Token efficiency trend (7-day rolling)
- Task completion velocity (7-day rolling)
- Test coverage trend
- Tool health status (color-coded)
- Upcoming tool maintenance needs

---

## 6. Agent Design & Implementation Specifics

### 6.1 Agent Personality & Voice

**Tone**: Direct, pragmatic, data-driven
**Not**: Cheerleader energy, vague platitudes, unnecessary emojis
**Example Good**: "Your system prompt is 6KB. Typical efficiency gain: 15% less wasted tokens. Want me to trim it?"
**Example Bad**: "Your system prompt is amazing! Let's make it even MORE amazing by trimming it!"

### 6.2 Agent Capabilities (Skills/Tools to Implement)

#### Capability A: Project Analyzer
- Reads git status, file structure, PROJECT_STATE.md
- Detects patterns: uncommitted changes, test failures, stale files
- Outputs: Health report with 1-3 actionable suggestions

#### Capability B: Token Optimizer
- Analyzes system prompts, tool definitions, file structures
- Detects waste: duplication, oversized files, unused tools
- Outputs: Specific refactoring suggestions with token savings estimate

#### Capability C: Workflow Advisor
- Recognizes common patterns in requests
- Suggests efficiency improvements based on context
- Offers templates or pre-built solutions

#### Capability D: Tool Health Monitor
- Tracks tool usage, staleness, conflicts
- Reports on tool ROI (token cost vs usage)
- Suggests removals, replacements, upgrades

#### Capability E: Documentation Generator
- Creates PROJECT_STATE.md from session
- Generates weekly summaries
- Updates architecture docs from code changes

### 6.3 Agent System Prompt Core Elements

Key sections:
1. **Mission**: Clear statement of purpose
2. **Philosophy**: Why efficiency matters (token budgets are real constraints)
3. **Approach**: Pragmatic, data-driven, transparent
4. **Scope**: What agent does/doesn't do
5. **Tone**: Direct, no fluff
6. **Examples**: Concrete good/bad patterns

---

## 7. Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
- [ ] Create agent system prompt (see 6.3)
- [ ] Implement Project Analyzer (6.2.A)
- [ ] Create PROJECT_STATE.md template
- [ ] Document 5 critical mistakes (from section 3)

### Phase 2: Core Features (Week 3-4)
- [ ] Implement Token Optimizer (6.2.B)
- [ ] Create reusable prompt templates
- [ ] Build Workflow Advisor (6.2.C)
- [ ] Document optimization patterns (section 1)

### Phase 3: Monitoring (Week 5-6)
- [ ] Implement Tool Health Monitor (6.2.D)
- [ ] Create weekly summary generator
- [ ] Build proactive nudges system (section 4)
- [ ] Define metrics dashboard (section 5)

### Phase 4: Polish (Week 7-8)
- [ ] Refine based on real usage
- [ ] Create command shortcuts
- [ ] Build documentation generator (6.2.E)
- [ ] User testing & iteration

---

## 8. Key Files to Create/Maintain

### For the Agent Itself
- `.claude/agent-system.md` - Agent system prompt
- `.claude/agent-commands/` - Agent-specific slash commands
  - `/analyze-project` - Run health check
  - `/optimize-tokens` - Token efficiency audit
  - `/suggest-workflow` - Workflow improvements
  - `/monitor-tools` - Tool health report

### For Users
- `.claude/PROJECT_STATE.md` - Template for state tracking
- `.claude/prompts/` - Reusable prompt templates
  - `architecture-review.md`
  - `performance-audit.md`
  - `security-check.md`
  - `feature-planning.md`

---

## 9. Integration Points with Claude Code

### With Settings.local.json
- Read permissions for tool analysis
- Suggest permission refinements based on actual tool usage

### With Slash Commands
- Create `/optimize` command that runs full audit
- Create `/project-health` for quick status
- Create `/suggest-next-task` for workflow guidance

### With MCP Servers
- Could integrate with GitHub MCP to analyze PR patterns
- Could use Memory Bank MCP to track metrics over time
- Could use Context7 MCP to suggest relevant docs

### With Skills
- Use python-development:python-performance-optimization to profile sessions
- Use document-skills:xlsx to create metric dashboards
- Use python-development:python-testing-patterns for test coverage analysis

---

## 10. Success Criteria

The agent is successful when:
1. Users reduce setup time for new projects (goal: < 30 min)
2. Users reduce wasted tokens by 20%+ on average
3. Users maintain 85%+ task completion rate
4. Users adopt PROJECT_STATE.md pattern (90%+ adoption)
5. Users find 2+ optimization opportunities per week
6. Agent adds < 1KB to typical system prompt
7. Users report agent as "helpful without being pushy" (80%+ satisfaction)

---

**Created**: 2025-10-29
**Purpose**: Comprehensive design specification for Claude Code Workflow Optimization Agent
**Audience**: Agent developers, implementation team
