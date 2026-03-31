# Claude Code Optimizer: Reference Files Structure

This document outlines the reference files you should create in `~/.claude/knowledge/` directory to support the claude-code-optimizer agent.

## File Organization

Create these files in `~/.claude/knowledge/`:

### 1. AGENT_PATTERNS.md (1000-1200 tokens)

**Purpose**: Define when and how to create agents, with canonical examples

**Key Sections**:
- When to create an agent (criteria)
- When NOT to create an agent
- Required components and structure
- System prompt guidelines
- 2-3 canonical agent examples
- Common pitfalls
- Token budget recommendations (600-1000 tokens)

**Example structure**:
```
# Agent Design Patterns

## When to Create an Agent
✓ Multi-step workflows
✓ Proactive guidance needed
✓ Maintains state across sessions
[etc.]

✗ Single query/answer
✗ Pure reference material
[etc.]

## Agent Structure Template
Required sections:
- Name & description (50 tokens)
- Purpose statement (100 tokens)
- Capabilities list (200 tokens)
- Behavioral traits (100 tokens)
- Knowledge base (80 tokens)
- Response approach (100 tokens)
Total: 630 tokens

## Canonical Examples
1. [Example agent 1 - Library/Documentation specialist]
2. [Example agent 2 - Code generation specialist]
3. [Example agent 3 - Project architect]

## Common Pitfalls
- Combining too many unrelated domains
- Oversized system prompts (> 1500 tokens)
- Insufficient behavioral trait specification
[etc.]

## Token Budget
[Table of recommended sizes for different types of agents]
```

### 2. SKILL_PATTERNS.md (1000-1200 tokens)

**Purpose**: Define when and how to create skills

**Key Sections**:
- When to create a skill (vs agent vs command)
- Skill structure and components
- Writing effective knowledge base content
- Example patterns from working skills
- Common pitfalls
- Token budget (1000-2000 tokens typical)

### 3. MCP_INTEGRATION.md (800-1000 tokens)

**Purpose**: Guide on integrating MCP servers with Claude Code

**Key Sections**:
- What is MCP and when to use it
- MCP server vs agent tools vs built-in tools
- Creating custom MCP servers
- Configuration patterns
- 1-2 canonical examples
- Common integration patterns

### 4. CONFIG_PATTERNS.md (600-800 tokens)

**Purpose**: Best practices for organizing Claude Code configurations

**Key Sections**:
- ~/.claude/config.json structure
- Agent/skill enablement patterns
- Marketplace configuration
- Per-project configuration overrides
- Plugin management
- Status line customization
- Common organization patterns

### 5. TOKEN_OPTIMIZATION.md (1000-1500 tokens)

**Purpose**: Token efficiency techniques and budgets

**Key Sections**:
- Token budgets by component type (table)
- Information layering principle
- Specific token-saving techniques:
  - Cross-reference instead of inline
  - Summarize then link
  - Capability lists vs descriptions
  - Example consolidation
  - Feature list indexing
- Before/after examples showing savings
- Common bloat patterns to avoid
- Tools for counting and monitoring

### 6. DECISION_TEMPLATES.md (400-600 tokens)

**Purpose**: Templates for documenting architectural decisions

**Key Sections**:
- ADR (Architectural Decision Record) format
- PROJECT_STATE.md template
- When to create an ADR vs inline documentation
- Examples from real projects

### 7. NAMING_CONVENTIONS.md (300-400 tokens)

**Purpose**: Consistent naming for agents, skills, commands, and files

**Key Sections**:
- Agent naming (domain-focus pattern)
- Skill naming (capability-focused)
- Command naming (action-focused)
- File and directory structure
- Examples from real projects

### 8. CLAUDE_CODE_FEATURES_INDEX.md (500-800 tokens)

**Purpose**: Quick index of Claude Code features with links

**Key Sections**:
- Agents (what they are, reference to AGENT_PATTERNS.md)
- Skills (what they are, reference to SKILL_PATTERNS.md)
- MCP Servers (what they are, reference to MCP_INTEGRATION.md)
- Commands (what they are, brief definition)
- Configuration system
- Marketplace and plugins
- Built-in tools available to agents
- Each entry links to detailed reference file

## Template Files to Create

In `~/.claude/templates/`:

### agent-template.md

```markdown
---
name: [domain]-[specialist]
description: [One sentence describing expertise and purpose]
model: sonnet
---

# [Full Name] Agent

You are the **[Full Name]** - [brief statement of expertise].

## Your Purpose
[One paragraph about role and when to use]

## Core Capabilities
- Capability 1
- Capability 2
- Capability 3

## Behavioral Traits
- Trait 1
- Trait 2

## Knowledge Base
[Brief overview of what you know]

## Response Approach
[3-5 steps for how you approach problems]

## Example Interactions
- "Example question 1"
- "Example question 2"
```

### skill-template.md

```markdown
---
name: [capability-name]
description: [One line about the skill]
---

# [Skill Title]

[Brief description of skill purpose]

## When to Use This Skill
- Use case 1
- Use case 2
- Use case 3

## Core Concepts

### Concept 1
[Explanation and examples]

### Concept 2
[Explanation and examples]

## Patterns

### Pattern 1
[Description and code example]

### Pattern 2
[Description and code example]

## Best Practices
[Bulleted best practices]

## Common Pitfalls
[What to avoid]

## Resources
- [Reference 1]: Location
- [Reference 2]: Location
```

### project-state-template.md

```markdown
# Project: [PROJECT_NAME]

**Status**: Active / On-Hold / Complete
**Last Updated**: [DATE]
**Primary Agent**: [Agent name if using]

## Organizational Structure

### Agents
| Name | Purpose | Status | Location |
|------|---------|--------|----------|
| | | | |

### Skills
| Name | Purpose | Status | Location |
|------|---------|--------|----------|
| | | | |

### MCP Servers
| Name | Purpose | Status | Location |
|------|---------|--------|----------|
| | | | |

## Key Decisions

### Architecture
[Link to ADR files for major decisions]

### Constraints & Preferences
- [Key constraint or preference]

## Optimization Backlog
- [ ] Item 1 (rationale)
- [ ] Item 2 (rationale)

## Quick Links
- Config: path/to/config.json
- Main Agent: path/to/agent.md
- Reference: ~/.claude/knowledge/
- History: ~/.claude/file-history/
```

### adr-template.md

```markdown
# ADR [NUMBER]: [TITLE]

**Status**: Proposed / Accepted / Deprecated / Superseded by ADR [X]
**Date**: [YYYY-MM-DD]
**Author**: [Your name]

## Context
[What is the issue that we're seeing that is motivating this decision?]

## Decision
[What is the change that we're proposing or have decided to do?]

## Rationale
[Why did we decide to do it this way?]

## Consequences
**Positive**:
- [Positive consequence 1]

**Negative**:
- [Negative consequence 1]

## Alternatives Considered
1. [Alternative 1]: Why rejected
2. [Alternative 2]: Why rejected

## Related Decisions
- ADR [X]: [Related decision]
```

## Directory Structure After Setup

```
~/.claude/
├── CLAUDE.md
├── config.json
│
├── agents/
│   ├── claude-code-optimizer.md     # Main agent
│   └── README.md                    # Index
│
├── knowledge/
│   ├── AGENT_PATTERNS.md            # 1200 tokens
│   ├── SKILL_PATTERNS.md            # 1200 tokens
│   ├── MCP_INTEGRATION.md           # 1000 tokens
│   ├── CONFIG_PATTERNS.md           # 800 tokens
│   ├── TOKEN_OPTIMIZATION.md        # 1500 tokens
│   ├── DECISION_TEMPLATES.md        # 600 tokens
│   ├── NAMING_CONVENTIONS.md        # 400 tokens
│   ├── CLAUDE_CODE_FEATURES_INDEX.md # 700 tokens
│   └── README.md                    # Index of all knowledge files
│
├── templates/
│   ├── agent-template.md
│   ├── skill-template.md
│   ├── project-state-template.md
│   ├── adr-template.md
│   └── README.md
│
└── projects/
    └── [project-name]/
        ├── PROJECT_STATE.md         # Project-specific state
        ├── adr/
        │   ├── 001-agent-architecture.md
        │   └── 002-[decision].md
        └── configs/
            └── [project-specific files]
```

## Priority of Knowledge Files

Create these in order:

**Week 1** (Critical):
1. AGENT_PATTERNS.md (you'll refer to this constantly)
2. TOKEN_OPTIMIZATION.md (core principle for all recommendations)
3. agent-template.md (template for creating agents)

**Week 2** (Important):
4. SKILL_PATTERNS.md
5. CONFIG_PATTERNS.md
6. project-state-template.md

**Week 3** (Useful):
7. MCP_INTEGRATION.md
8. CLAUDE_CODE_FEATURES_INDEX.md
9. NAMING_CONVENTIONS.md
10. DECISION_TEMPLATES.md
11. adr-template.md

## How the Agent Uses These Files

**System Prompt**: References these files but doesn't include their full content
- "See AGENT_PATTERNS.md for when to create agents"
- "See TOKEN_OPTIMIZATION.md for token budgets"

**When User Asks Specific Question**: Agent loads relevant file
- "Should I create an agent or skill?" → Load AGENT_PATTERNS.md + SKILL_PATTERNS.md
- "How much should my prompt be?" → Load TOKEN_OPTIMIZATION.md
- "How do I organize my config?" → Load CONFIG_PATTERNS.md

**When Recommending Something New**: Agent references template
- "Here's an agent template from ~/.claude/templates/agent-template.md"
- Provides customized version for user's specific case

## Content Quality Guidelines

**For AGENT_PATTERNS.md**:
- Include 2-3 real agents you've created (anonymized if needed)
- Explain decision tree: Is it multi-step? → Does it need state? → etc.
- Show real examples of good vs bad agent structures
- Provide token budget table

**For TOKEN_OPTIMIZATION.md**:
- Include before/after examples of real system prompts
- Show actual token count reductions achieved
- Provide specific techniques with code examples
- Make it data-driven, not opinionated

**For SKILL_PATTERNS.md**:
- Reference skills from marketplace you find well-designed
- Show structure of effective skills
- Include examples of knowledge that should be in skills

**For CONFIG_PATTERNS.md**:
- Show real config.json examples
- Explain best practices for your specific workflow
- Include examples of per-project overrides

## Maintaining These Files

**Update Schedule**:
- Review quarterly for accuracy
- Update whenever you create a new agent/skill pattern
- Add lessons learned from successful projects
- Record anti-patterns you discover

**Versioning**:
- Keep in git if you're version controlling your Claude setup
- Date your updates in file headers
- Note when content was last reviewed/validated

---

**Note**: These reference files are the knowledge base for your claude-code-optimizer agent. Keep them accurate, current, and concise. They serve as both reference material and living documentation of your Claude Code best practices.
