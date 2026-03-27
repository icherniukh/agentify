# Integration with Other Skills/Agents

The context-window-inspector skill is designed to work with other Claude Code skills and agents:

## Core Integration Points

### config‑cleaner agent
- **Shared patterns**: File‑existence checking, @‑include parsing, and token‑estimation logic
- **Complementary roles**: config‑cleaner identifies stale references; context‑window‑inspector estimates token impact
- **Workflow**: Run config‑cleaner first to fix broken references, then inspector to optimize token usage

### self‑audit skill
- **Invocation**: self‑audit can invoke context‑window‑inspector as part of comprehensive configuration audits
- **Phase coordination**: Inspector runs during Phase 2 (configuration analysis) of self‑audit
- **Output integration**: Inspector's report feeds into self‑audit's final recommendations

### Scout agent
- **Pre‑build analysis**: Scout searches for existing MCP servers before building new ones; inspector quantifies their token cost
- **Cost‑aware decisions**: Use inspector's MCP server overhead estimates to decide whether to add another server
- **Discovery‑validation loop**: Scout finds servers → inspector measures impact → user decides

### git‑context‑recovery skill
- **Historical analysis**: git‑context‑recovery traces when configuration bloat began by analyzing git history of CLAUDE.md and settings.json
- **Time‑based insights**: Correlate configuration changes with token overhead increases
- **Blame attribution**: Identify which commit introduced high‑cost patterns

### reduce‑hallucinations skill
- **Validation**: reduce‑hallucinations ensures @‑include content matches what's claimed in configuration
- **Accuracy foundation**: Inspector relies on accurate file contents for token estimation
- **Joint verification**: Both skills cross‑validate configuration integrity

### round skill
- **Session notes**: round adds optimization suggestions when context overhead is high
- **Continuity**: Inspector's findings become round notes for next session
- **Progress tracking**: Track token reduction across sessions via round's history

## Workflow Examples

### Complete Configuration Audit
1. **git‑context‑recovery** → Analyze history of CLAUDE.md changes
2. **config‑cleaner** → Remove broken references, stale files
3. **reduce‑hallucinations** → Verify @‑include content accuracy
4. **context‑window‑inspector** → Measure token overhead, identify optimization targets
5. **self‑audit** → Compile findings into comprehensive audit report
6. **round** → Document decisions and plan next session

### MCP Server Optimization
1. **Scout** → Search for existing servers that could replace needed functionality
2. **context‑window‑inspector** → Quantify current server overhead
3. **config‑cleaner** → Remove unused server configurations
4. **round** → Note decision to disable/consolidate servers

### New Project Setup
1. **context‑window‑inspector** → Baseline measurement of global configuration overhead
2. **config‑cleaner** → Ensure no stale references in project CLAUDE.md
3. **reduce‑hallucinations** → Validate any @‑includes
4. **round** → Record setup decisions for future reference

## Skill Dependencies

The context‑window‑inspector has **no hard dependencies** on other skills — it can run standalone. However, integration enhances its value:

- **Optional but recommended**: config‑cleaner, self‑audit, git‑context‑recovery
- **Situational**: Scout (when considering new MCP servers), reduce‑hallucinations (when @‑includes are complex)
- **Always useful**: round (for session continuity)

## Installation Order

When setting up a comprehensive Claude Code configuration optimization suite:

1. Install **context‑window‑inspector** (this skill)
2. Install **config‑cleaner** agent
3. Install **self‑audit** skill
4. Install **git‑context‑recovery** skill
5. Install **round** skill
6. Install **reduce‑hallucinations** skill (optional)
7. Install **Scout** agent (optional)

## Shared Patterns

All these skills/agents follow consistent patterns:

- **Token estimation**: `chars ÷ 4` heuristic
- **File existence checking**: `test -f` with proper path resolution
- **@‑include parsing**: `grep -E '@[a-zA-Z0-9_.-]+\.md'`
- **Report formatting**: Markdown tables with severity classifications (Remove/Review/Consolidate/Optimize)
- **Action prioritization**: High token impact first, low effort fixes early

## References

- [config‑cleaner agent](../../../agents/config-cleaner.md)
- [self‑audit skill](../../self-audit/SKILL.md)
- [git‑context‑recovery skill](../../git-context-recovery/SKILL.md)
- [reduce‑hallucinations skill](../../reduce-hallucinations/SKILL.md)
- [round skill](../../round/SKILL.md)
- [Scout agent](../../../agents/scout.md)