# Claude Code Optimizer: Direct Answers to Your Questions

This document provides direct answers to each of your 6 questions, with specific implementation guidance.

---

## Question 1: Should this be an agent or a skill? Why?

### Answer: AGENT (with optional supporting SKILL)

### Primary Recommendation: AGENT

**Why Agent**:

1. **Proactive Guidance**
   - You want it to suggest optimizations without being prompted
   - Agents can maintain personality and behavioral traits that drive proactive behavior
   - Skills are passive; agents are active advisors

2. **Multi-Step Workflows**
   - Configuration analysis → identification → recommendation → implementation
   - Needs to orchestrate across multiple actions
   - Agent can guide you through step-by-step process

3. **State Management**
   - Needs to remember your preferences and decisions across sessions
   - PROJECT_STATE.md serves as memory store that agent reads
   - Can learn patterns from your history

4. **Tool Orchestration**
   - Needs read/write access to configs and documentation
   - Must execute commands (bash for Claude Code operations)
   - Needs to generate files and update documentation

5. **Domain Expertise**
   - Should maintain specialized perspective on Claude Code optimization
   - Has decision authority about agent vs skill vs command
   - Serves as "organizational advisor" not "information lookup"

### Why NOT Just a Skill:

- Skills can't be proactive (they're looked up, not called)
- Skills have no behavioral traits or personality
- Skills don't maintain conversational memory
- Skills are reference materials, not advisors

### Hybrid Approach (Optional):

You could also create:
- **Agent**: `claude-code-optimizer` (Main advisor, orchestrator)
- **Skill**: `claude-code-patterns` (Reference material supporting the agent)
  - Contains detailed pattern libraries
  - Agent references it in recommendations
  - Shared across multiple agents if needed

**For now**: Just create the AGENT. Skills can be added later if knowledge gets too large.

---

## Question 2: What tools should it have access to?

### Answer: Read, Write, Edit, Bash, Glob, Grep, Todo

### Required Tools

| Tool | Purpose | Examples |
|------|---------|----------|
| **Read** | Examine configs and documentation | Read agent definitions, PROJECT_STATE.md, config.json |
| **Write** | Create new config files and documentation | Create PROJECT_STATE.md, create reference files, create ADRs |
| **Edit** | Modify existing configurations | Update system prompts, modify config.json |
| **Bash** | Execute Claude Code commands | Run `claude` CLI, check file structure, git operations |
| **Glob** | Find configuration files | Find all agents, find all skills, find reference files |
| **Grep** | Search across configurations | Find patterns, search history, find duplicate definitions |
| **Todo** | Track optimization projects | Keep backlog of improvements in PROJECT_STATE.md |

### Tools NOT Needed

- **WebFetch**: Not needed (everything is local)
- **WebSearch**: Not needed (no external references)
- **NotebookEdit**: Not needed (not working with notebooks)
- **Skill**: Don't invoke other skills from this agent
- **SlashCommand**: Don't invoke other commands from this agent

### Optional Tools

- **Bash (with run_in_background)**: For long-running analysis
- **BashOutput**: For monitoring background operations

---

## Question 3: How should I structure the prompt for context efficiency?

### Answer: 3-Tier Layered Architecture (400-600 tokens system prompt)

### System Prompt Structure

#### Tier 1: Always in System Prompt (400-600 tokens total)

```
1. Role & Authority (30 tokens)
   "You are the Claude Code Optimization Specialist..."

2. Your Personal Preferences (50 tokens)
   From ~/.claude/CLAUDE.md
   - Do NOT use analogies
   - Maintain project state files
   - Be technical

3. Decision Framework (120 tokens)
   When to recommend agent/skill/command
   Token budgets for each type

4. Project Context (100-150 tokens)
   - Reference to PROJECT_STATE.md
   - Summary of decisions
   - Known constraints

5. Response Approach (100 tokens)
   How you operate step-by-step
   Format for recommendations

Total: ~400-600 tokens
```

#### Tier 2: Load Dynamically When Needed (Saves Tokens)

- Detailed agent patterns → Load AGENT_PATTERNS.md (1200 tokens)
- Skill design patterns → Load SKILL_PATTERNS.md (1200 tokens)
- Token techniques → Load TOKEN_OPTIMIZATION.md (1500 tokens)
- MCP patterns → Load MCP_INTEGRATION.md (1000 tokens)

### Token Savings Example

**Without Layering**: 2500+ token system prompt + 2500+ per query = 5000+ total
**With Layering**: 600 token system prompt + 1200-1500 loaded files = 2000-2100 total
**Savings**: 55-60% fewer tokens for same capability

---

## Question 4: What information should be in system prompt vs dynamically fetched?

### Answer: Decision Matrix

| Information | System Prompt | Dynamic | Rationale |
|-------------|---------------|---------|-----------|
| Role & expertise | ✓ | | Define who you are |
| Your preferences | ✓ | | Small (50 tokens) |
| Decision framework | ✓ | | Core logic (120 tokens) |
| Specific techniques | | ✓ | Load TOKEN_OPTIMIZATION.md on demand |
| Pattern examples | | ✓ | Load AGENT_PATTERNS.md when needed |
| Feature descriptions | | ✓ | Load SKILL_PATTERNS.md when needed |
| Historical context | | ✓ | Grep history when analyzing |
| Template code | | ✓ | Load templates when creating |
| Reference materials | | ✓ | Load on demand |
| Project state summary | ✓ | | Brief summary (100 tokens) |

---

## Question 5: How can I make it token-efficient while maintaining comprehensive knowledge?

### Answer: Information Layering + Strategic Loading

### Five Key Techniques

1. **Capability Lists vs Descriptions**
   - Instead of: 200 tokens describing REST API patterns
   - Use: "REST API design (resource models, versioning)" = 10 tokens
   - Load details on demand

2. **Index with Cross-References**
   - System prompt: Lists reference files + brief descriptions
   - Files contain comprehensive patterns
   - Load files only when user needs details

3. **Summarize + Link**
   - System prompt: 100 token summary of key principles
   - System prompt: Link to detailed reference file
   - System prompt: One canonical example

4. **Template Consolidation**
   - System prompt: "Templates available in ~/.claude/templates/"
   - Actual templates in files (load when creating new component)
   - Saves 400+ tokens per template

5. **Load Only What's Asked**
   - Don't preload all reference files
   - User mentions "agent" → load AGENT_PATTERNS.md
   - User mentions "tokens" → load TOKEN_OPTIMIZATION.md

### Realistic Token Budgets

| Approach | System Prompt | Average Query |
|----------|---------------|----------------|
| Everything inline | 3000+ | 3000+ |
| Strategic layering | 600 | 2000-2500 |
| **Savings** | **80%** | **33%** |

---

## Question 6: Should it maintain state/memory across sessions? How?

### Answer: YES, via PROJECT_STATE.md (File-based, not agent memory)

### How It Works

**Session 1**: Claude analyzes setup
- Writes decisions to PROJECT_STATE.md
- Creates ADR files for major decisions
- Documents optimization backlog

**Session 2**: Claude reads PROJECT_STATE.md
- Learns what was already decided
- Continues from where previous session left off
- References ADR files for context

**Session 3**: Claude extends memory
- Updates PROJECT_STATE.md with new learnings
- Creates new ADRs as new decisions emerge
- Refines patterns based on experience

### Memory Storage: PROJECT_STATE.md

```markdown
# Project: [NAME]

**Status**: Active
**Last Updated**: [DATE]

## Organizational Structure
[Current agents, skills, MCP servers]

## Key Decisions
[Links to ADR files]

## Constraints & Preferences
[Known requirements]

## Optimization Backlog
- [ ] Item 1 (pending/in-progress/completed)
- [ ] Item 2
```

### Supplementary: ADR Files

For major decisions, create ADR (Architectural Decision Record):

```markdown
# ADR 001: Single-Agent Architecture

**Status**: Accepted
**Date**: 2025-10-29

## Decision
Use single agent (claude-code-optimizer) for focus

## Rationale
- Single agent easier to coordinate
- Layering reduces token usage 60-70%
- PROJECT_STATE.md keeps memory auditable

## Consequences
**Positive**: Focused expertise, low tokens, auditable
**Negative**: Must manually update PROJECT_STATE.md
```

### Why File-Based Memory?

1. **Auditable**: You can see all decisions
2. **Version-Controllable**: Track changes with git
3. **Shareable**: Other agents can reference same decisions
4. **Durable**: Survives Claude Code version updates
5. **Human-Readable**: You can update directly

### Memory Over Time

```
Week 1: Creates PROJECT_STATE.md
        Discovers: "Information layering saves 60% tokens"
        Backlog: [ ] Populate reference files

Week 2: Reads: PROJECT_STATE.md (knows history)
        Continues: Optimization backlog items
        Updates: TOKEN_OPTIMIZATION.md with new lessons

Week 3: Reads: ADRs (knows previous reasoning)
        Creates: ADR-002-canonical-agent-types
        Recommends: 3 agent archetypes all fit into
```

---

## Summary Table

| Question | Answer | Key Detail |
|----------|--------|-----------|
| 1. Agent or skill? | **Agent** | Proactive, multi-step, orchestration |
| 2. What tools? | **Read, Write, Edit, Bash, Glob, Grep, Todo** | Full file + command access |
| 3. Prompt structure? | **3-tier layering** | 600 tokens core + dynamic loads |
| 4. System vs dynamic? | **Core logic in prompt, patterns in files** | Load on-demand principle |
| 5. Token efficiency? | **Information layering** | 60-70% fewer tokens, same knowledge |
| 6. State/memory? | **Yes, via PROJECT_STATE.md** | File-based, not agent memory |

---

## Files Provided

1. **CLAUDE_CODE_OPTIMIZER_DESIGN.md** - Comprehensive design document (12,000 tokens)
2. **claude-code-optimizer-agent.md** - Complete system prompt (2,000 tokens)
3. **REFERENCE_FILES_STRUCTURE.md** - How to organize knowledge files
4. **IMPLEMENTATION_QUICKSTART.md** - Step-by-step setup guide
5. **ANSWERS_TO_QUESTIONS.md** - This file (direct answers)

All files are in `/Users/ivan/proj/up_claude/`

---

## Implementation Path

**This Week**:
1. Copy agent to ~/.claude/agents/claude-code-optimizer.md
2. Create minimal knowledge files
3. Create PROJECT_STATE.md
4. Test with agent

**Next Week**:
1. Populate knowledge files
2. Create ADRs for decisions
3. Document patterns
4. Set up templates

**Ongoing**:
1. Keep PROJECT_STATE.md current
2. Update knowledge files
3. Use agent for new designs
4. Review backlog periodically
