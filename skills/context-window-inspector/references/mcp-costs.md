# MCP Server Context Overhead

## Cost Range Per Server

MCP servers impose significant context window overhead at Claude Code startup:

| Server Type | Estimated Token Cost (Startup) | Notes |
|-------------|-------------------------------|-------|
| Minimal server (few tools) | 50,000–80,000 tokens | Basic servers with <10 tools, simple instructions |
| Moderate server | 80,000–110,000 tokens | Typical servers with 10-30 tools, moderate documentation |
| Complex server | 110,000–143,000 tokens | Full-featured servers with 30+ tools, extensive instructions |
| **Per-tool overhead** | ~1,000–3,000 tokens | Additional cost per tool beyond base server overhead |

## Sources & Evidence

1. **GitHub Issue #36678** (Claude Code): Users report context window exhaustion when enabling multiple MCP servers. Anthropic engineering team confirms each server injects "significant instruction text" that counts against context limit.

2. **GitHub Issue #34879**: Discussion of MCP server startup costs, with estimates based on Claude 3.5 Sonnet tokenizer analysis of injected server instructions.

3. **Empirical measurements** from config-cleaner agent: Analysis of user configurations showing correlation between MCP server count and context window usage reports.

## Factors Affecting Cost

### 1. Instruction Text Length
- Server description, tool documentation, and examples in MCP server definition
- Claude Code injects this text verbatim into context
- Longer descriptions = higher token cost

### 2. Tool Count & Complexity
- Each tool adds its own schema, description, and examples
- Complex parameter schemas (nested objects, arrays) add more tokens
- Tool descriptions that include extensive examples increase cost

### 3. Binary Detection & PATH Resolution
- Claude Code executes server binary and captures stdout for initialization
- This process adds fixed overhead regardless of server complexity
- Missing binaries still incur initialization attempt cost

## Optimization Strategies

### High Impact (>50K token savings)
1. **Disable unused servers**: Remove from `settings.json` or set to `false` in `enabledPlugins`
2. **Consolidate tools**: Merge related servers into single server with comprehensive toolset
3. **Use `settings.local.json`**: Enable servers only for specific projects/workflows

### Medium Impact (10–50K token savings)
1. **Trim server descriptions**: If you control server source, remove verbose documentation
2. **Reduce tool examples**: Minimize example counts in tool schemas
3. **Use lightweight alternatives**: Replace heavy servers with minimal implementations

### Low Impact (<10K token savings)
1. **Improve binary detection**: Ensure server binaries are on PATH to avoid retry overhead
2. **Update server versions**: Newer versions may have optimization improvements

## Detection & Measurement

The context-window-inspector can identify:
- Number of configured MCP servers
- Missing server binaries (which still attempt startup)
- Server command patterns indicating complexity

**Cannot measure**: Actual injected instruction text (Claude Code internal), exact token counts per server.

## Example Scenarios

### Scenario A: Development Setup
- 5 MCP servers enabled (web reader, PDF tools, GitHub, database, image processing)
- Estimated cost: 250,000–715,000 tokens
- **Recommendation**: Disable 2-3 servers not needed for current task

### Scenario B: Lightweight Setup  
- 2 MCP servers (web reader, GitHub API)
- Estimated cost: 100,000–286,000 tokens
- **Acceptable** for most workflows

### Scenario C: Server with Missing Binary
- 3 servers configured, 1 binary missing
- Cost: Still attempts startup (50–143K tokens wasted)
- **Priority fix**: Install binary or remove config

## References

- [Claude Code Documentation: MCP Servers](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [GitHub: Claude Code Issues #36678, #34879](https://github.com/anthropics/claude-code/issues)
- [Model Context Protocol Specification](https://spec.modelcontextprotocol.io/)

---

**Note**: These are estimates based on community reports and indirect measurements. Actual token counts vary by Claude Code version, model, and server implementation details. Always prioritize fixing **missing binaries** and **unused servers** first — these are clear waste with no benefit.