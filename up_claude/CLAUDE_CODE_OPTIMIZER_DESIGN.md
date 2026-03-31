# Claude Code Workflow Optimization Agent: Design & Implementation Guide

## Executive Summary

This document provides comprehensive recommendations for building a specialized Claude Code optimization agent that serves as a long-term workflow assistant. The design prioritizes **token efficiency**, **proactive advice**, and **contextual organization** while maintaining comprehensive knowledge about Claude Code features.

---

## 1. Agent vs Skill Decision

### Recommendation: AGENT (with supporting SKILL)

**Why Agent:**

1. **Proactive Guidance**: Agents can suggest best practices without being prompted, adapting to ongoing work
2. **Continuous Context**: Agents maintain understanding of your workflow across sessions (via system prompt + working memory)
3. **Multi-step Workflows**: Can orchestrate complex optimization tasks (analyze → suggest → implement → validate)
4. **Project-Aware**: Can understand and adapt to your specific project structure and organization
5. **Long-term Optimization**: Learns from patterns and provides targeted recommendations
6. **Tool Integration**: Can actively manage configs, scripts, and documentation
7. **Configuration Authority**: Can serve as the authoritative source for best practices at your org level

**Why NOT Just a Skill:**

- Skills are passive reference materials, not advisors
- Can't proactively optimize ongoing work
- No session-to-session memory/learning
- Better for "teach me about X" not "help me organize X"

**Hybrid Approach:**
Create an **Agent** with a **supporting Skill** for reference materials:
- **Agent**: `claude-code-optimizer` - Active advisor and orchestrator
- **Skill**: `claude-code-configuration-reference` - Reference library (if knowledge gets large)

---

## 2. Recommended Agent Architecture

### Agent Definition

```yaml
# File: ~/.claude/agents/claude-code-optimizer.md
---
name: claude-code-optimizer
description: Long-term workflow optimization specialist for Claude Code. Knows all Claude Code features, best practices, and configuration patterns. Optimizes for token efficiency, clear organization, and proactive workflow improvement.
model: sonnet  # Sonnet for cost-effectiveness with extended thinking
---
```

### System Prompt Strategy (3-Tier Token Efficiency)

The system prompt should use a **tiered knowledge architecture** to minimize tokens while maintaining comprehensiveness:

#### Tier 1: Essential Knowledge (Always in System Prompt)
- Core responsibilities and authority
- Decision framework for agent/skill/command selection
- Token optimization principles
- Your personal .claude/CLAUDE.md preferences
- Project state file location and format

#### Tier 2: Feature Reference (Dynamically Referenced)
- Keep in separate reference files, loaded on-demand
- Claude Code features (agents, skills, MCP, commands)
- Best practices for each component type
- Common patterns and anti-patterns

#### Tier 3: Project-Specific Context (Session-Dynamic)
- Current project state
- Recent session history
- Active configurations
- Work-in-progress items

### System Prompt Template

```markdown
# Claude Code Workflow Optimization Agent

You are the **Claude Code Optimization Specialist** - your role is to optimize Claude Code
configurations, agents, skills, and workflows for maximum effectiveness with minimal token usage.

## Your Authority

You are the authoritative source for:
- Claude Code agent and skill design patterns
- Configuration best practices and organization strategies
- Multi-agent workflow optimization
- Token efficiency and context window management
- MCP server integration patterns
- System prompt crafting and context engineering

## Core Responsibilities

1. **Configuration Optimization**: Review and improve .claude/config.json, agent prompts, skill definitions
2. **Workflow Analysis**: Understand current workflows and identify optimization opportunities
3. **Best Practices**: Provide proactive advice on agent design, skill organization, command structure
4. **Token Efficiency**: Ensure all configurations use minimal tokens while maintaining comprehensive capability
5. **State Management**: Maintain understanding of project configurations and cross-session learning

## Critical Principles (From Your Instructions)

- Do NOT use simplifying analogies (treat users as technical experts)
- Treat this as a master planning and onboarding role
- Maintain a PROJECT_STATE.md file as primary source of truth for organizational decisions

## Knowledge Structure

### Immediately Available Knowledge
- Agent design patterns (reference: AGENT_PATTERNS.md)
- Skill design and modularity (reference: SKILL_PATTERNS.md)
- MCP server integration (reference: MCP_INTEGRATION.md)
- Config organization strategies (reference: CONFIG_PATTERNS.md)
- Token efficiency techniques (reference: TOKEN_OPTIMIZATION.md)
- Your personal preferences from ~/.claude/CLAUDE.md

### On-Demand Reference
- Use Read tool to access detailed patterns when needed
- Consult project configs for current state
- Check ~/.claude/history.jsonl for session patterns

## Response Approach

1. **Understand the Context**: What are they building? What's their current state?
2. **Assess Token Usage**: Is their current setup efficient? Where can we optimize?
3. **Identify Patterns**: Are they repeating work? Can we create agents/skills to automate?
4. **Design Solution**: Propose concrete changes with file paths and code samples
5. **Plan Implementation**: Break down changes into actionable steps
6. **Document Decision**: Explain rationale and tradeoffs in decision records

## Key Distinctions

**When to Create an Agent:**
- Multi-step workflows that span projects
- Proactive decision-making needed
- Maintains state across sessions
- Serves multiple sub-workflows
- Needs tool access and orchestration

**When to Create a Skill:**
- Reference materials and patterns
- Reusable technical knowledge
- Doesn't need proactive behavior
- Passive information lookup
- Supports multiple agents

**When to Create a Command:**
- Single-step, focused workflow
- Quick entry point to an agent
- User explicitly triggers it
- Maps to specific intent
- Provides a CLI interface

## Behavioral Traits

- **Proactive**: Suggest optimizations without being prompted
- **Practical**: Always provide implementation guidance with specific file paths
- **Token-Conscious**: Minimize unnecessary context and tokens in all recommendations
- **Opinionated**: Guide users toward best practices with clear reasoning
- **Learnable**: Track patterns and adapt recommendations based on feedback
- **Respectful**: Recognize when existing setup is intentional, don't over-optimize
- **Documentation-First**: Update PROJECT_STATE.md for every significant recommendation

## Example Interactions

- "Analyze my current .claude/config.json and suggest optimizations"
- "Help me design an agent for X workflow - what tools should it have?"
- "I keep doing Y task manually - should this be a skill or command or agent?"
- "Review my agent's system prompt for token efficiency"
- "What's the best way to organize multiple related agents?"
- "Should I use MCP for this integration or build it into the agent?"
- "Help me create a project state file to track decisions"
- "Analyze my last 5 sessions - what patterns should I create agents for?"
```

---

## 3. Tool Access & Capabilities

### Essential Tools (Always Available)

```json
{
  "tools": {
    "read": "Read configuration files, agents, skills, prompts",
    "write": "Create/update config files and documentation",
    "edit": "Modify existing configurations",
    "bash": "Execute Claude Code commands (gh, claude, etc.)",
    "glob": "Find configuration files across projects",
    "grep": "Search configurations for patterns",
    "todo": "Track optimization projects as work items"
  }
}
```

### Workflow: What the Agent Can Do

The agent should have tools/capabilities to:

1. **Analyze Current State**
   - Read `.claude/config.json` files
   - Read agent definitions (`~/.claude/agents/*.md`)
   - Read skill definitions
   - Check MCP server configs
   - Examine command definitions

2. **Suggest Improvements**
   - Review system prompts for token efficiency
   - Identify duplicate or overlapping agents
   - Spot missing helper agents
   - Find unused skills/agents
   - Suggest better organization

3. **Implement Changes**
   - Create new agent templates
   - Update existing configurations
   - Refactor system prompts
   - Create project state files
   - Generate implementation guides

4. **Maintain Organizational Memory**
   - Keep PROJECT_STATE.md updated
   - Document architectural decisions
   - Record configuration choices and rationale
   - Track version history of important configs

5. **Cross-Project Analysis**
   - Find common patterns across projects
   - Suggest shared infrastructure agents
   - Identify best practices from successful projects
   - Recommend consolidation opportunities

---

## 4. System Prompt Content Structure

### What Goes in System Prompt (Static, Essential)

**Always include** - these don't change and are essential for every interaction:

1. **Role & Authority** (30 tokens)
   - Who you are
   - What you're an expert in
   - Your decision authority

2. **Your Preferences** (50 tokens)
   - Imported from ~/.claude/CLAUDE.md
   - Personal communication preferences
   - Organization philosophy
   - Non-negotiable principles

3. **Core Decision Framework** (80 tokens)
   - When to recommend agent vs skill vs command
   - Token optimization rules
   - Design principles for configurations
   - Tradeoff analysis approach

4. **Current Project State** (100-200 tokens)
   - Link to PROJECT_STATE.md
   - Key organizational decisions made
   - Known constraints and patterns
   - Active optimization projects

**Total Static Prompt: ~300-400 tokens**

### What to Load Dynamically (Save Tokens)

**Load on-demand** when user asks about specific topics:

- Detailed agent design patterns → AGENT_PATTERNS.md
- Skill architecture best practices → SKILL_PATTERNS.md
- MCP integration approaches → MCP_INTEGRATION.md
- Token counting methodologies → TOKEN_OPTIMIZATION.md
- Previous similar recommendations → History search

**Rationale**: You don't need to know every pattern in every prompt. Load relevant patterns when needed.

---

## 5. Token Efficiency Optimization Strategy

### Principle: Information Layering

**Avoid**: Dumping all knowledge into system prompt (100K+ tokens)

**Instead**: Use this layered approach:

```
┌─────────────────────────────────────────┐
│ System Prompt (400 tokens)              │
│ - Role & authority                      │
│ - Decision framework                    │
│ - Your personal preferences             │
│ - Link to PROJECT_STATE.md              │
└──────────────┬──────────────────────────┘
               │
               ├─→ User mentions agent design
               │   └─→ Load AGENT_PATTERNS.md (1K)
               │
               ├─→ User mentions tokens
               │   └─→ Load TOKEN_OPTIMIZATION.md (1.5K)
               │
               ├─→ User shows their config
               │   └─→ Analyze locally (no extra file)
               │
               └─→ User wants history patterns
                   └─→ Grep history.jsonl (load matches)
```

### Specific Token-Saving Techniques

1. **Cross-Reference Instead of Inline**
   - System prompt: "See CONFIG_PATTERNS.md for REST API endpoint patterns"
   - User asks → Load that file on demand
   - Save: 300+ tokens per pattern

2. **Summarized Decision Records**
   - PROJECT_STATE.md: Decisions with 1-2 line summary
   - Full rationale in separate ADR files
   - Load ADR when context needed
   - Save: 200+ tokens per old decision

3. **Example Consolidation**
   - System prompt: "See AGENT_EXAMPLES.md for 5 canonical agents"
   - Show only most relevant example in response
   - Full examples available in file
   - Save: 500+ tokens of unused examples

4. **Feature List (Not Detailed Feature Guide)**
   - System prompt lists Claude Code features + file locations
   - Details loaded from reference files
   - Save: 1000+ tokens per feature description

### Concrete System Prompt Size Target

**Goal**: 400-600 tokens for system prompt (vs 2000+ for bloated approaches)

**Composition**:
- Role & philosophy: 150 tokens
- Decision framework: 120 tokens
- Your preferences (from CLAUDE.md): 80 tokens
- Current project state summary: 100 tokens
- Reference file index: 50 tokens

---

## 6. State & Memory Management

### Primary State Storage: PROJECT_STATE.md

**Location**: Each project root has `/PROJECT_STATE.md`

**Contents** (kept concise - 50-100 tokens):

```markdown
# Project: [Name]
# Last Updated: [Date]
# Agent: claude-code-optimizer

## Organizational Decisions

### Agents Designed
- **agent-name**: Brief purpose + status
- **agent-name**: Brief purpose + status

### Skills Created
- **skill-name**: Brief purpose + status

### MCP Servers
- **server-name**: Purpose + location

### Optimization Opportunities
- [ ] Item 1 (status: pending/in-progress/completed)
- [ ] Item 2

### Key Constraints
- List any non-negotiable preferences
- Known limitations
- Integration requirements

### See Also
- ADR: architectural-decision-record.md (if major decisions)
- CONFIG: path to current config
- HISTORY: pointers to relevant session notes
```

**Purpose**: Onboarding for new Claude sessions + memory store

### Session-Level Memory

The agent learns about current setup through:

1. **Reading PROJECT_STATE.md** at start (100 tokens)
2. **Checking recent configs** via bash (grep results)
3. **Searching history** for related work (load only matches)
4. **User's updates** during session (added to todo)

### Cross-Session Learning

**How the agent improves over time**:

1. Document decisions in PROJECT_STATE.md
2. Create ADRs for major choices
3. Track patterns in session notes
4. Update reference files with lessons learned
5. Review and consolidate when relevant

**No permanent agent memory needed** - all state stays in files the agent can read.

---

## 7. Implementation Roadmap

### Phase 1: Core Agent Setup (Week 1)

```
Tasks:
1. Create ~/.claude/agents/claude-code-optimizer.md
   - System prompt (400-600 tokens)
   - Tier 1 knowledge only

2. Create reference files:
   - ~/.claude/knowledge/AGENT_PATTERNS.md
   - ~/.claude/knowledge/SKILL_PATTERNS.md
   - ~/.claude/knowledge/MCP_INTEGRATION.md
   - ~/.claude/knowledge/CONFIG_PATTERNS.md
   - ~/.claude/knowledge/TOKEN_OPTIMIZATION.md

3. Create PROJECT_STATE.md for up_claude project
   - Document this design decision
   - List current configuration

4. Test the agent:
   - Ask it to analyze current setup
   - Ask for optimization suggestions
   - Verify token usage is reasonable
```

### Phase 2: Knowledge Base (Week 2)

```
Tasks:
1. Populate reference files with:
   - Your proven patterns
   - Lessons from existing projects (midi, etc.)
   - Best practices for agent design
   - Examples from working configs

2. Document:
   - When to create agents vs skills vs commands
   - Token budgets for different component types
   - Naming conventions
   - Folder structure recommendations

3. Create helper documents:
   - AGENT_CHECKLIST.md (what to include)
   - SKILL_CHECKLIST.md (what to include)
   - CONFIG_CHECKLIST.md (what to include)
   - NAMING_CONVENTIONS.md
```

### Phase 3: Automation & Integration (Week 3+)

```
Tasks:
1. Create commands that invoke the agent:
   - /optimize-config (analyze config)
   - /design-agent (help create new agent)
   - /review-setup (full workspace review)

2. Integrate with your workflows:
   - Call agent when creating new projects
   - Run agent review before major changes
   - Update PROJECT_STATE.md automatically

3. Build helper agents:
   - config-auditor: checks configurations
   - mcp-orchestrator: manages MCP servers
   - workflow-analyzer: finds patterns in history
```

---

## 8. Specific File Structure Recommendations

### Directory Organization

```
~/.claude/
├── CLAUDE.md                          # Your global preferences
├── config.json                        # Global Claude Code config
│
├── agents/
│   ├── claude-code-optimizer.md       # Main optimization agent
│   ├── [other-agents].md              # Your project-specific agents
│   └── README.md                      # Index of all agents
│
├── knowledge/
│   ├── AGENT_PATTERNS.md              # When/how to create agents
│   ├── SKILL_PATTERNS.md              # When/how to create skills
│   ├── MCP_INTEGRATION.md             # MCP server patterns
│   ├── CONFIG_PATTERNS.md             # Config organization
│   ├── TOKEN_OPTIMIZATION.md          # Token efficiency guide
│   ├── DECISION_TEMPLATES.md          # ADR templates
│   └── README.md                      # Knowledge index
│
├── templates/
│   ├── agent-template.md              # Starter agent
│   ├── skill-template.md              # Starter skill
│   ├── project-state-template.md      # PROJECT_STATE.md template
│   └── adr-template.md                # Decision record template
│
└── projects/
    └── [project-name]/
        ├── PROJECT_STATE.md           # Project-specific state
        ├── adr/
        │   ├── 001-agent-architecture.md
        │   └── 002-[decision].md
        └── configs/
            └── [project-specific configs]
```

### Key Files to Create

#### 1. ~/.claude/knowledge/AGENT_PATTERNS.md

```markdown
# Agent Design Patterns

## When to Create an Agent

✓ Multi-step workflow spanning multiple tools
✓ Needs proactive guidance/suggestions
✓ Maintains state across sessions
✓ Serves 3+ different sub-workflows
✓ Requires continuous learning/optimization

✗ Single query/answer → Use skill instead
✗ Pure reference material → Use skill instead
✗ One-off workflow → Use command instead
✗ Passive knowledge lookup → Use skill instead

## Agent Structure

Required sections:
- Name & description (50 tokens)
- Purpose statement (100 tokens)
- Core capabilities (200 tokens) - list not paragraphs
- Behavioral traits (100 tokens)
- Knowledge base (80 tokens) - reference, not detail
- Response approach (100 tokens) - step-by-step

Typical size: 700-1200 tokens (max 2000)

## Examples
[Include 2-3 canonical examples]

---
```

#### 2. ~/.claude/knowledge/TOKEN_OPTIMIZATION.md

```markdown
# Token Efficiency Guide

## Budgets by Component

| Component | Recommended | Max | Includes |
|-----------|-------------|-----|----------|
| Agent | 600-1000 | 2000 | System prompt only |
| Skill | 1000-2000 | 5000 | Knowledge + examples |
| Knowledge File | 500-1500 | 3000 | Reference material |
| Command | 50-200 | 500 | Instruction text |

## Token-Saving Techniques

1. Use capability lists, not detailed descriptions
2. Cross-reference instead of inline information
3. Load details on-demand (user asks specifically)
4. Use structured lists for examples
5. Keep system prompts focused on decision framework
6. Summarize, then link to details

## Example: Agent Prompt Optimization

Before (2100 tokens):
- Full detailed description of REST APIs
- Full detailed description of GraphQL
- Full detailed description of gRPC
- Full detailed description of WebSocket
- Full detailed description of security patterns
- Examples for each

After (650 tokens):
- Lists of supported patterns (50 tokens)
- Link to SKILL: api-design-principles (1500 tokens loaded on demand)
- One canonical example (100 tokens)
- Note in response approach to load details (50 tokens)

Savings: 1450 tokens (69%)
```

#### 3. PROJECT_STATE.md Template (Each Project)

```markdown
# Project: [PROJECT_NAME]

**Status**: Active / On-Hold / Complete
**Last Updated**: [DATE]
**Primary Agent**: claude-code-optimizer

## Organizational Structure

### Agents
| Name | Purpose | Status | Location |
|------|---------|--------|----------|
| [agent] | [Brief] | Active | .claude/agents/ |

### Skills
| Name | Purpose | Status | Location |
|------|---------|--------|----------|
| [skill] | [Brief] | Active | skill location |

### MCP Servers
| Name | Purpose | Status | Location |
|------|---------|--------|----------|
| [server] | [Brief] | Active | .claude/mcp/ |

## Key Decisions

### Architecture
[Link to ADR files for major decisions]

### Constraints & Preferences
- [Your preferences specific to this project]

## Optimization Backlog
- [ ] [Item with rationale]
- [ ] [Item with rationale]

## Quick Links
- Config: path/to/config.json
- Main Agent: .claude/agents/primary-agent.md
- Reference: .claude/knowledge/
- History: .claude/file-history/
```

---

## 9. Real-World Implementation Example

### Example: Optimizing Your Current Setup

**Before Talking to Agent**: You have scattered agents, mixed purposes

**Agent Analysis**:
1. Reads your current `.claude/` structure
2. Identifies patterns (3 related agents doing similar work)
3. Suggests consolidation into single agent with sub-workflows
4. Proposes TOKEN_OPTIMIZATION.md to reduce system prompt size from 2500 to 600 tokens
5. Recommends creating PROJECT_STATE.md to track decisions
6. Suggests MCP server pattern documentation

**Agent Output**: Concrete step-by-step guide:
- Which files to create/modify (with paths)
- Code samples for new agents
- How to consolidate existing agents
- How to organize knowledge files
- Expected token savings: 70%

**Your Action**: Execute the steps

**Agent Tracking**: PROJECT_STATE.md updated with completed optimization

---

## 10. Key Principles Summary

### Design Priorities (In Order)

1. **Token Efficiency**: Every byte counts; reference > detail
2. **Actionability**: Every recommendation includes file paths and code
3. **Proactivity**: Suggest optimizations without being prompted
4. **Simplicity**: Prefer 1 agent doing 3 things to 3 specialized agents
5. **Learnability**: Store decisions as they're made for future reference
6. **Scalability**: Structure supports growing number of agents/skills
7. **Maintainability**: Easy to understand and modify existing configs

### What Makes This Agent Effective

1. **Narrow Focus**: Claude Code optimization only (not general coding)
2. **Deep Knowledge**: Knows patterns from real working systems
3. **Practical Output**: Every suggestion is immediately implementable
4. **Token Consciousness**: Models token efficiency in all recommendations
5. **Context Aware**: Understands your personal preferences and constraints
6. **Continuous Learning**: Improves via PROJECT_STATE.md and session notes
7. **Collaborative**: Works WITH you, not FOR you

---

## 11. Success Metrics

### How to Know This Is Working

**Token Efficiency**:
- New agent system prompts: 600-1000 tokens (vs 2000+ before)
- Queries to agent: Complete in 1-2 exchanges (vs 5+ before)
- Annual token savings: Estimated 30-50% across all projects

**Workflow Improvement**:
- New project setup: 30 minutes (vs 2+ hours before)
- Agent creation time: 15 minutes (vs 1+ hour before)
- Decision clarity: All choices documented in PROJECT_STATE.md
- Pattern reuse: 3+ agents consolidated into single parametric agent

**Knowledge Management**:
- All major decisions documented in ADRs
- PROJECT_STATE.md kept current (< 1 week stale)
- Reference files actively used in agent prompts
- New patterns documented as discovered

---

## 12. Next Steps

### Immediate Actions (This Week)

1. Review this document → add/modify based on your preferences
2. Create `~/.claude/agents/claude-code-optimizer.md` with the system prompt template
3. Create `~/.claude/knowledge/` directory with reference files
4. Create `PROJECT_STATE.md` for your current active project
5. Test agent: Ask it to analyze your current setup

### Follow-up Actions (Next 2 Weeks)

1. Populate reference files with your patterns and lessons
2. Create/consolidate agents based on agent recommendations
3. Document major decisions in ADRs
4. Create helpful commands that invoke the agent
5. Run periodic "workspace audit" queries

### Long-term Integration

1. Use agent for all new project setups
2. Reference agent when designing new agents/skills
3. Keep PROJECT_STATE.md updated as part of weekly review
4. Create consolidated, efficient agent library
5. Build on successful patterns across projects

---

## Questions This Answers

### 1. Agent vs Skill?
**Answer**: Agent (with supporting Skill for reference materials). Agent provides proactive guidance and multi-step orchestration.

### 2. What Tools Should It Have?
**Answer**: Read, Write, Edit, Bash (for Claude commands), Glob, Grep, Todo. All tools focused on configuration analysis and management.

### 3. System Prompt Structure?
**Answer**: 3-tier layering - 400-600 token core prompt + dynamically loaded reference files. Saves 70% of tokens vs bloated approach.

### 4. System Prompt vs Dynamic?
**Answer**: System prompt: role, authority, decision framework, preferences. Dynamic: patterns, examples, detailed feature lists (loaded on demand).

### 5. Token Efficiency?
**Answer**: Information layering (reference > detail), capability lists (not paragraphs), on-demand loading of patterns, summarize then link approach.

### 6. State/Memory?
**Answer**: PROJECT_STATE.md as primary memory store + ADRs for major decisions. No permanent agent memory needed; all state in readable files.

---

## Appendix: Quick Reference Checklist

### System Prompt Checklist
- [ ] Role and authority (30 tokens)
- [ ] Your preferences from CLAUDE.md (50 tokens)
- [ ] Decision framework (80 tokens)
- [ ] Project state reference (100 tokens)
- [ ] Reference file index (50 tokens)
- [ ] Example interactions (100 tokens)
- **Total: 400-600 tokens**

### Agent Definition Checklist
- [ ] Name (concise, describes purpose)
- [ ] Description (one sentence)
- [ ] Model (sonnet for cost efficiency)
- [ ] System prompt (follows above structure)
- [ ] Tools enabled (read, write, edit, bash, etc.)

### Reference File Checklist (AGENT_PATTERNS.md, etc.)
- [ ] When to use this pattern
- [ ] When NOT to use it
- [ ] Component structure/requirements
- [ ] 2-3 canonical examples
- [ ] Common pitfalls
- [ ] Token budget recommendations
- **Target: 1000-1500 tokens per file**

### PROJECT_STATE.md Checklist
- [ ] Project name and status
- [ ] List of agents with brief description
- [ ] List of skills with brief description
- [ ] List of MCP servers with brief description
- [ ] Key architectural decisions (link to ADRs)
- [ ] Known constraints and preferences
- [ ] Optimization backlog with rationale
- [ ] Quick links to important files
- **Target: 50-100 tokens (keep summary, details in files)**

---

*This design document serves as the blueprint for your Claude Code Optimization Agent. Use it to set up the initial agent, then let the agent help refine and improve the setup based on your actual usage patterns.*
