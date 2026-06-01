# Scout Ecosystem Sources

Use this file as Scout's source map. Refresh live before making recommendations; do not treat counts, popularity, or install commands here as permanently current.

## Primary Sources

| Source | Use For | Refresh Check |
| --- | --- | --- |
| `github.com/anthropics/skills` | Official Agent Skills examples, spec, and Claude Code plugin marketplace install patterns | Check README and marketplace instructions |
| `github.com/anthropics/claude-code` | Claude Code plugin/skill implementation examples and current behavior | Check plugin docs and recent issues when behavior matters |
| `github.com/ccplugins/marketplace` | Community Claude Code plugin marketplace entries | Check repository activity and manifest format |
| `github.com/jeremylongshore/claude-code-plugins-plus` | Large Claude Code plugin collection and plugin install examples | Check README counts, categories, and install syntax |
| `github.com/wshobson/agents` | Cross-runtime agents, skills, and commands | Check runtime support table and repo freshness |
| `github.com/obra/superpowers` | Opinionated Claude Code skill/workflow collection | Check current skill names and install flow |
| `skills.sh` / `skillsmp.com` | Agent Skills discovery and install counts | Verify counts and package IDs live |
| `github.com/modelcontextprotocol/registry` | MCP registry service and discovery model | Prefer this over random lists when looking for MCP servers |
| `github.com/modelcontextprotocol/servers` | Official/community MCP server references and links to registry | Check README for deprecations and moved packages |
| `docs.perplexity.ai` and `github.com/perplexityai/modelcontextprotocol` | Perplexity Sonar/API docs and official MCP server for web search, ask, research, and reasoning | Distinguish read-only docs MCP from API-keyed search/research MCP; verify current package and tool names |

## Secondary Sources

Use these only as corroboration or for broader discovery:

- MCP directories such as `mcpfind.org`, `safemcp.info`, `mcpserver.info`, `mcpdrop.com`, and `modelcontext-protocol.com`.
- GitHub topic/code searches for `claude-code-plugin`, `agent-skills`, `claude-skills`, `mcp-server`, and specific domain terms.
- Community posts and discussions, clearly labeled as community evidence.

## Refresh Protocol

1. Search current web/GitHub first for the user's capability and the relevant source names.
2. Open the candidate's primary repo, marketplace page, or registry entry before scoring it.
3. Verify install syntax from the current source. Do not invent `/plugin`, `npx`, `uvx`, or `claude mcp` commands.
4. Check maintenance signals: recent commits/releases, open issues, README quality, license, stars/forks when available, and whether the project is a thin wrapper around an external API.
5. For MCP/plugin candidates, inspect requested permissions, environment variables, network calls, and whether secrets leave the machine.
6. Separate "can recommend" from "can install". Scout recommends; installation needs explicit user approval and the relevant runtime-specific installer.

## Tool Guidance

- `WebSearch` is enough for broad discovery and source lookup.
- Brave-backed search is useful for broad, fast SERP coverage and finding obscure community pages.
- Exa search/crawl/code-context tools are useful for semantic discovery, crawling candidate docs, and finding code examples inside repos.
- Perplexity-backed tools are useful for cited answer synthesis, deep research, and current web-grounded reasoning. Use them to augment discovery, not as the only evidence: open primary sources before scoring a candidate.
- If Exa or Brave MCP tools are unavailable, use `WebSearch` plus direct source fetches. Do not fail solely because enhanced search tools are absent.
