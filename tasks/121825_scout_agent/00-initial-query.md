# Initial Query

**Task:** Design a spec for a "Tool Finder" agent for Claude Code.

**Purpose:** An agent that searches the Claude Code ecosystem for existing solutions matching a problem statement. Given a problem like "I need observability into token usage" or "I want to improve my CLAUDE.md iteratively", it searches for existing plugins, agents, skills, MCPs, or community conventions that address that need.

**Requirements:**
1. Search capabilities - where should it look? (web, GitHub, marketplaces, community resources)
2. Analysis - how does it evaluate fit against the stated problem?
3. Presentation - how does it present findings? (summary, pros/cons, fit score, complexity)

**Deliverables:**
- Agent name (something memorable)
- Agent file content (markdown with YAML frontmatter for ~/.claude/agents/)
- Description of tools it needs access to
- Example invocation and expected output format

**Constraints:**
- Keep it focused and simple - avoid over-engineering
- Should be immediately usable after creation
- Leverage existing Claude Code capabilities (WebSearch, WebFetch, etc.)

Write the complete agent spec that could be deployed to ~/.claude/agents/ immediately.
