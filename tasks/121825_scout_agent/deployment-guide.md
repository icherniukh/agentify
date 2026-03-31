# Scout Agent - Deployment Guide

## Quick Deploy

Copy the agent file to your Claude Code agents directory:

```bash
cp scout.md ~/.claude/agents/scout.md
```

Restart Claude Code or reload the window. Scout is now available.

## Verification

Test Scout with:
```
Scout, what MCP servers exist for database access?
```

Expected behavior: Scout searches ecosystem and returns structured report with top matches.

## Usage Patterns

### 1. Direct Invocation
```
Scout, I need observability into token usage. What exists?
```

### 2. Task Delegation (from main Claude)
```
Let me delegate to Scout to find existing solutions first.
[Uses Task tool with agent: "scout"]
```

### 3. Optional Slash Command

Create `/scout` shortcut:

```bash
mkdir -p ~/.claude/slash-commands
cat > ~/.claude/slash-commands/scout.md << 'EOF'
Invoke Scout agent to search Claude Code ecosystem for existing solutions to the stated problem.
EOF
```

Usage: `/scout [problem description]`

## Integration with Kim

Scout complements Kim's configuration work:

**Workflow:**
1. User describes need to Kim
2. Kim delegates to Scout to search ecosystem
3. Scout reports findings
4. Kim installs/configures recommended solution (if approved)

Example:
```
User: "Kim, I want better test coverage reporting."
Kim: "Let me check what exists first..."
[Kim delegates to Scout]
Scout: [Returns report with pytest-coverage-mcp]
Kim: "Scout found pytest-coverage-mcp with High fit. Install it?"
User: "Yes"
Kim: [Configures MCP server]
```

## Tools Required

Scout uses:
- WebSearch (ecosystem discovery)
- WebFetch (fetch documentation/READMEs)
- Read (check local installations)
- Grep (search local configs)
- Glob (discover installed plugins)

All tools are standard Claude Code capabilities - no additional setup needed.

## Maintenance

Update Scout's primary sources when:
- New major marketplaces launch
- Ecosystem consolidation occurs
- Search quality degrades

Edit `~/.claude/agents/scout.md` and update the "Search Scope > Primary sources" section.

## Success Metrics

Scout is working well when:
- 80%+ searches return at least one Medium+ fit
- Users choose existing over building 60%+ of time
- Time-to-discovery averages <5 minutes
- False positive rate <20%

Track usage over time to calibrate search sources and ranking.
