# Claude Code Optimizer: Implementation Quickstart

Quick checklist to get your optimization agent up and running in 30 minutes.

## Step 1: Create the Agent (5 minutes)

Copy the agent definition to your Claude Code installation:

```bash
# Copy the agent file to your Claude Code agents directory
cp /Users/ivan/proj/up_claude/claude-code-optimizer-agent.md \
   ~/.claude/agents/claude-code-optimizer.md
```

Verify it works:
```bash
# This should show your agent is installed
ls -la ~/.claude/agents/claude-code-optimizer.md
```

## Step 2: Create Knowledge Directory (2 minutes)

```bash
# Create the knowledge directory if it doesn't exist
mkdir -p ~/.claude/knowledge
mkdir -p ~/.claude/templates
mkdir -p ~/.claude/projects
```

## Step 3: Create Minimal Knowledge Files (15 minutes)

These are the absolute minimum needed to make the agent useful.

### TOKEN_OPTIMIZATION.md
```markdown
# Token Efficiency Guide

## Component Size Budgets

| Component | Recommended | Max | Notes |
|-----------|-------------|-----|-------|
| Agent system prompt | 600-1000 | 2000 | Keep focused on decision framework |
| Skill knowledge base | 1000-2000 | 5000 | Comprehensive reference material |
| Command definition | 50-200 | 500 | Just instruction text |
| Knowledge file | 500-1500 | 3000 | Reference material, load on demand |

## Token-Saving Techniques

1. **Information Layering**: Core prompt + dynamic references
   - Instead of 3000 token detailed description
   - Use 600 token core + link to 2000 token reference file
   - Load reference only when user asks

2. **Capability Lists**: Bullet list, not paragraphs
   - Instead of: "The agent can manage REST APIs by designing resource hierarchies..."
   - Use: "- REST API design (resource models, versioning, pagination)"

3. **Cross-Reference Pattern**:
   - Instead of: [full feature description inline]
   - Use: "See REFERENCE_FILE.md for detailed patterns"

4. **Example Consolidation**:
   - Instead of: Multiple detailed examples in system prompt
   - Use: One canonical example in prompt, rest in reference file

5. **Load on Demand**:
   - System prompt: Knows these patterns exist, doesn't describe them
   - User asks specific question: Load relevant reference file
   - User gets full answer from loaded file

## Real Example: Agent Design

### Before (2100 tokens)
```
Your system prompt includes:
- Detailed description of when to create agents (200 tokens)
- Detailed description of when to create skills (200 tokens)
- Detailed description of when to create commands (150 tokens)
- 5 different examples of agents (600 tokens)
- 5 different examples of skills (600 tokens)
- Token budget tables (150 tokens)
- Common pitfalls (200 tokens)
```

### After (650 tokens)
```
Your system prompt includes:
- Lists of when to use each component (100 tokens)
- Link to AGENT_PATTERNS.md (reference 1500 tokens loaded on demand)
- Link to SKILL_PATTERNS.md (reference 1500 tokens loaded on demand)
- One canonical example (100 tokens)
- Note in response approach: "Load AGENT_PATTERNS.md if user asks details" (50 tokens)
- Token budget summary (100 tokens)

When user asks "How do I design an agent?":
- Agent loads AGENT_PATTERNS.md
- Provides comprehensive answer with examples
- No extra tokens wasted in system prompt
```

**Savings: 1450 tokens (69%) in system prompt with better answers**

## Reference Files to Create

Create files in `~/.claude/knowledge/`:

### AGENT_PATTERNS.md (Keep it ~1200 tokens)
```markdown
# Agent Design Patterns

## When to Create an Agent

✓ Multi-step workflow (3+ actions)
✓ Needs proactive guidance
✓ Maintains state across sessions
✓ Serves 3+ sub-workflows
✓ Requires tool orchestration

✗ Single query/answer → Skill instead
✗ Pure reference → Skill instead
✗ One-off → Command instead
✗ Passive lookup → Skill instead

## Agent Structure

Required sections (typical sizes):
- Name & description: 50 tokens
- Purpose statement: 100 tokens
- Core capabilities: 200 tokens (bullet list)
- Behavioral traits: 100 tokens (bullet list)
- Knowledge base: 80 tokens (brief overview)
- Response approach: 100 tokens (step-by-step)

**Total: 630 tokens (well within 1000 token budget)**

## Canonical Example: Library Agent

For a project with many reference materials, create a specialist:

\`\`\`
---
name: project-librarian
description: Reference specialist for [project] documentation and specifications
model: sonnet
---

# [Project] Librarian

You are the authoritative specialist for project documentation...

## Purpose
Answer questions about project specifications, architecture, design decisions...

## Core Capabilities
- Hardware specifications and constraints
- Protocol specifications (MIDI, Rekordbox, Pioneer)
- Architecture and design decisions
- Project specifications and requirements
- Historical decisions and alternatives

## Knowledge Base
You have complete access to:
- Hardware manuals
- Official protocol documentation
- Project architectural specs
- Decision records (ADRs)
- Reference implementations

## Response Approach
1. Identify the relevant reference material
2. Read the specific sections
3. Provide sourced answers with citations
4. Clarify ambiguities
5. Explain context and rationale
\`\`\`

## Canonical Example: Code Generation Agent

For a project that frequently generates code:

\`\`\`
---
name: [language]-code-generator
description: Expert code generation for [project]. Masters patterns, conventions, and project standards.
model: sonnet
---

# [Project] Code Generator

You are the **[Language] Code Generation Specialist**...
\`\`\`

## Token Budgets by Agent Type

| Type | Typical | Max | Examples |
|------|---------|-----|----------|
| Reference/Library | 600-800 | 1200 | Librarian, Specification expert |
| Code Generation | 700-900 | 1200 | Code generator, Refactorer |
| Architecture | 800-1000 | 1500 | Architect, Designer |
| Orchestration | 600-800 | 1000 | Coordinator, Optimizer |

## Common Pitfalls

1. **Oversized prompts** (> 1500 tokens)
   - Symptom: Slow response time
   - Solution: Move details to reference files

2. **Missing behavioral traits**
   - Symptom: Agent seems generic/unfocused
   - Solution: Add 5-7 specific traits

3. **Combining too many domains**
   - Symptom: Agent tries to be expert in everything
   - Solution: Split into focused agents, have them reference each other

4. **Not using tools**
   - Symptom: Agent can't access needed files/configs
   - Solution: Enable Read, Write, Edit, Bash tools
```

### SKILL_PATTERNS.md (Keep it ~1200 tokens)
```markdown
# Skill Design Patterns

## When to Create a Skill

✓ Reference material or knowledge base
✓ Reusable by multiple agents
✓ Doesn't need proactive behavior
✓ Passive information lookup
✓ Examples and detailed patterns

✗ Needs proactive guidance → Agent instead
✗ One project only → Consider agent instead
✗ Needs state management → Agent instead

## Skill Structure

- Description: What expertise does it provide
- When to use: Clear use cases
- Core concepts: Main ideas (with examples)
- Patterns: Common usage patterns
- Best practices: Do's and don'ts
- Common pitfalls: What to avoid
- Resources: Links to external references

## Size Guidelines

- Small skill: 1000 tokens (core concepts only)
- Medium skill: 1500 tokens (concepts + patterns)
- Large skill: 2000 tokens (comprehensive reference)
- Maximum: 5000 tokens (only if truly comprehensive)

## Examples

From the marketplace:
- API Design Principles: REST/GraphQL design patterns (1500 tokens)
- Backend Architecture: Microservices patterns (2000 tokens)
- Python Testing Patterns: Test design strategies (1500 tokens)
```

### CONFIG_PATTERNS.md (Keep it ~800 tokens)
```markdown
# Configuration Organization Patterns

## Standard ~/.claude/ Structure

```
~/.claude/
├── CLAUDE.md                 # Your global preferences
├── config.json              # Global Claude Code settings
├── agents/                  # Your custom agents
├── knowledge/               # Reference material
├── templates/               # Templates for new components
└── projects/                # Project-specific state
    └── [project]/
        ├── PROJECT_STATE.md
        └── adr/
```

## config.json Best Practices

1. **Keep it minimal**: Only what differs from defaults
2. **Version your config**: Check into git
3. **Don't commit secrets**: Use environment variables
4. **Document enabled plugins**: Note why each is enabled

Example:
\`\`\`json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  },
  "enabledPlugins": {
    "agent-optimization@claude-code-workflows": true,
    "context-management@claude-code-workflows": true,
    "python-development@claude-code-workflows": true
  }
}
\`\`\`

## PROJECT_STATE.md Structure

```markdown
# Project: [NAME]

**Status**: Active
**Last Updated**: [DATE]

## Organization
- Agents: [list]
- Skills: [list]
- MCP Servers: [list]

## Key Decisions
[Link to ADR files]

## Optimization Backlog
- [ ] Item 1
- [ ] Item 2
```

## Per-Project Config Overrides

Some projects may need different settings:
\`\`\`
project-folder/
├── .claude/
│   └── config.json          # Project-specific overrides
├── PROJECT_STATE.md
└── [project files]
\`\`\`
```

### AGENT_TEMPLATES.md (Keep it ~500 tokens)
```markdown
# Agent Templates

Use these as starting points when creating new agents.

## Basic Agent Template

\`\`\`yaml
---
name: [domain]-[specialist]
description: [One-line description of expertise]
model: sonnet
---
\`\`\`

\`\`\`markdown
# [Full Name] Agent

You are the **[Name]** - [brief expertise statement].

## Your Purpose
[One paragraph about role and when to use]

## Core Capabilities
- Capability 1
- Capability 2
- Capability 3

## Behavioral Traits
- Trait 1
- Trait 2

## Response Approach
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Example Interactions
- "Example question 1"
- "Example question 2"
\`\`\`

## Size Target: 600-800 tokens
```

## Step 4: Create PROJECT_STATE.md for Your Main Project (5 minutes)

Create this file in your main project directory:

```markdown
# Project: up_claude

**Status**: Active
**Last Updated**: 2025-10-29
**Primary Agent**: claude-code-optimizer

## Organizational Structure

### Agents
| Name | Purpose | Status | Location |
|------|---------|--------|----------|
| claude-code-optimizer | Claude Code configuration and workflow optimization specialist | Active | ~/.claude/agents/claude-code-optimizer.md |

### Skills
(None yet - to be added as projects scale)

### MCP Servers
(None yet - to be added as needed)

## Key Decisions

### Agent Architecture
- Created single, focused optimization agent vs multiple specialized agents
- Chose agent over skill for proactive guidance capability
- Used Sonnet model for cost efficiency
- Implemented 3-tier knowledge system (core + reference + dynamic)

See: CLAUDE_CODE_OPTIMIZER_DESIGN.md for full rationale

### Token Efficiency
- System prompt: 600-1000 tokens (not 2000-5000)
- Reference files loaded on-demand
- Information layering principle

See: TOKEN_OPTIMIZATION.md for details

## Optimization Backlog
- [ ] Populate AGENT_PATTERNS.md with lessons from existing projects
- [ ] Populate SKILL_PATTERNS.md with skill design examples
- [ ] Create MCP_INTEGRATION.md with server patterns
- [ ] Document naming conventions in NAMING_CONVENTIONS.md
- [ ] Create command wrappers for common agent workflows

## Quick Links
- Design Document: /Users/ivan/proj/up_claude/CLAUDE_CODE_OPTIMIZER_DESIGN.md
- Agent Definition: ~/.claude/agents/claude-code-optimizer.md
- Knowledge Base: ~/.claude/knowledge/
- Templates: ~/.claude/templates/
- History: ~/.claude/history.jsonl
```

## Step 5: Test Your Setup (3 minutes)

Try asking your new agent questions:

```bash
# Test it! (This would be done within Claude Code)
# Ask questions like:
# - "Analyze my .claude/config.json and suggest optimizations"
# - "What's the difference between an agent and a skill?"
# - "Help me design an agent for [my workflow]"
# - "How can I make my system prompt more token-efficient?"
```

## Verification Checklist

- [ ] Agent file created at `~/.claude/agents/claude-code-optimizer.md`
- [ ] Knowledge directory created at `~/.claude/knowledge/`
- [ ] Minimal knowledge files created (TOKEN_OPTIMIZATION.md, AGENT_PATTERNS.md, SKILL_PATTERNS.md, CONFIG_PATTERNS.md)
- [ ] PROJECT_STATE.md created in your main project
- [ ] You can reference the agent in Claude Code
- [ ] Agent can read and write files in ~/.claude/

## Next Steps (After Initial Setup)

### Week 1
- Populate remaining knowledge files
- Create templates for agents, skills, commands
- Document your personal preferences

### Week 2
- Start using agent for new design questions
- Get recommendations on optimizing existing agents
- Create ADRs for major decisions

### Week 3+
- Continuously improve reference files based on real usage
- Track patterns that emerge
- Consolidate successful patterns into reusable templates

## File Locations Summary

After setup, you'll have:

```
~/.claude/
├── agents/
│   └── claude-code-optimizer.md          # Main agent

├── knowledge/
│   ├── TOKEN_OPTIMIZATION.md             # Created in step 3
│   ├── AGENT_PATTERNS.md                 # Created in step 3
│   ├── SKILL_PATTERNS.md                 # Created in step 3
│   ├── CONFIG_PATTERNS.md                # Created in step 3
│   └── [other files as needed]           # Created later

└── projects/
    └── up_claude/
        └── PROJECT_STATE.md               # Created in step 4

/Users/ivan/proj/up_claude/
├── CLAUDE_CODE_OPTIMIZER_DESIGN.md       # Design doc (reference only)
├── REFERENCE_FILES_STRUCTURE.md          # How to structure reference files
├── claude-code-optimizer-agent.md        # Full agent (copy to ~/.claude/agents/)
└── IMPLEMENTATION_QUICKSTART.md          # This file
```

---

**You're now ready to use your Claude Code Optimization Agent!**

Start by asking it to analyze your current setup, then follow its recommendations to optimize your configurations and workflows.
