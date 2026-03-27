# claude-mem Token Waste Investigation

**Date:** 2025-12-18  
**Finding:** claude-mem consumed 1.98M tokens with 0% ROI

## Key Metrics
- Total overhead: 1,976,009 tokens (~$30)
- Observations created: 521
- Evidence of cross-session reuse: None
- Overhead ratio: 5:1 (overhead to productive work)

## Root Cause
PostToolUse hook created observation after every Read/Grep/Glob/WebFetch.
Agents exploring codebases generated 95+ observations in 8 minutes.

## Action Taken
- Disabled plugin in settings.json
- Killed all processes
- Added Read/Grep/Glob/WebFetch/Task to SKIP_TOOLS

## Lesson
Memory systems need clear ROI measurement and project-scoped context.
Global context injection from unrelated projects = pure waste.
