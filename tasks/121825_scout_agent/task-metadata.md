# Task Metadata: Scout Agent Design

**Codename:** scout_agent
**Date:** 2025-12-18
**Status:** Completed

## Objective
Design a complete "Tool Finder" agent specification for Claude Code ecosystem discovery.

## Deliverables
- [x] Agent name and role definition - "Scout"
- [x] Complete agent markdown file with YAML frontmatter - scout.md
- [x] Tool requirements documentation - WebSearch, WebFetch, Read, Grep, Glob
- [x] Example invocations and output formats - 2 detailed examples included
- [x] Deployment instructions - deployment-guide.md

## Context
User needs an agent to search the Claude Code ecosystem (plugins, agents, skills, MCPs, conventions) for existing solutions to stated problems.

## Outcome

**Created:** Scout - Claude Code Ecosystem Discovery Specialist

**Files delivered:**
1. scout.md (deployable agent file - 356 lines)
2. scout-agent-spec.md (complete specification - 501 lines)
3. deployment-guide.md (installation guide - 97 lines)
4. summary.md (executive summary - 126 lines)

**Agent capabilities:**
- Searches 6+ primary ecosystem sources (Anthropic official, community marketplaces, skills aggregators)
- Analyzes fit (High/Medium/Low scoring)
- Evaluates complexity (Simple/Moderate/Complex)
- Provides structured reports with pros/cons, installation estimates
- Recommends build vs. buy decisions

**Tools assigned:** WebSearch, WebFetch, Read, Grep, Glob
**Model:** sonnet

**Key features:**
- Comprehensive ecosystem coverage (10000+ searchable skills)
- Quality indicators (stars, maintenance, adoption)
- Honest fit assessment (will recommend building if gaps exist)
- Integration with Kim for install/config workflow

**Deployment:** Ready for immediate use - copy scout.md to ~/.claude/agents/

**Impact:** Reduces reinvention of existing solutions, leverages community tools, saves development time
