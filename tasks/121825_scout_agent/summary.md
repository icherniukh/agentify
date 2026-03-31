# Scout Agent - Executive Summary

## Overview

**Agent Name:** Scout
**Role:** Claude Code Ecosystem Discovery Specialist
**Tagline:** "Find existing solutions before building new ones"

## Purpose

Scout searches the Claude Code ecosystem (plugins, agents, skills, MCP servers, conventions) for existing solutions matching a stated problem. It evaluates fitness, analyzes complexity, and presents actionable recommendations.

## Key Features

1. **Comprehensive Search**
   - Official Anthropic skills repository
   - Community marketplaces (ccplugins/marketplace, claude-code-plugins-plus)
   - Popular collections (wshobson/agents, obra/superpowers)
   - Skills aggregators (skillsmp.com - 10000+ skills)
   - MCP server directories

2. **Smart Analysis**
   - Fit scoring (High/Medium/Low)
   - Complexity assessment (Simple/Moderate/Complex)
   - Quality indicators (stars, maintenance, adoption)
   - Pros/cons for specific use case

3. **Structured Output**
   - Top 3-5 matches ranked by relevance
   - Build vs. buy recommendation
   - Direct links to sources
   - Installation complexity estimates

## Tools Required

- WebSearch (ecosystem discovery)
- WebFetch (documentation retrieval)
- Read (check local installations)
- Grep (search local configs)
- Glob (discover installed plugins)

All standard Claude Code tools - no additional setup needed.

## Example Use Cases

1. "Scout, I need observability into token usage. What exists?"
2. "Scout, what MCP servers are available for database access?"
3. "Scout, are there agents specialized in Python testing?"
4. "Scout, how do other people handle iterative CLAUDE.md improvement?"

## Deployment

**File:** `~/.claude/agents/scout.md` (ready to deploy - see scout.md in this directory)

**Installation:**
```bash
cp scout.md ~/.claude/agents/scout.md
# Restart Claude Code
```

**Verification:**
```
Scout, what MCP servers exist for database access?
```

## Integration Points

**With Kim (config specialist):**
- Kim delegates to Scout before building custom solutions
- Scout finds ecosystem options
- Kim installs/configures if approved

**With main Claude:**
- Use Task tool to delegate searches
- Scout provides research, main Claude implements

## Value Proposition

**Before Scout:**
- Developers build custom solutions unaware of existing tools
- Time wasted reinventing wheels
- Inconsistent solution quality

**After Scout:**
- Ecosystem-aware discovery in <5 minutes
- Leverage community solutions (better maintained)
- Build only when gaps exist

## Success Metrics

- 80%+ searches return Medium+ fit
- 60%+ choose existing over building
- <5 min average discovery time
- <20% false positive rate

## Files in This Deliverable

1. `scout-agent-spec.md` - Complete specification with examples (this file)
2. `scout.md` - Deployable agent file (copy to ~/.claude/agents/)
3. `deployment-guide.md` - Installation and usage instructions
4. `summary.md` - Executive summary (this document)
5. `00-initial-query.md` - Original task request
6. `task-metadata.md` - Task tracking metadata

## Ready to Deploy

Scout is production-ready. Copy `scout.md` to `~/.claude/agents/` and start using immediately.
