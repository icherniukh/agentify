# Token Estimation Accuracy

## Canonical Formula

The standard heuristic used across Claude Code configuration analysis:

```
estimated_tokens = character_count ÷ 4
```

### Accuracy & Error Range
- **Typical accuracy**: 80–90% for English text and code
- **Error range**: ±5–15% depending on content type
- **Best for**: Configuration files, documentation, markdown
- **Worst for**: Code with many symbols, non-English text, compressed data

## Why `chars ÷ 4`?

1. **Empirical baseline**: Claude's tokenizer averages ~4 characters per token for typical English text
2. **Community standard**: Used by config-cleaner agent, self-audit skill, and other Claude Code tools
3. **Computationally simple**: No external dependencies, works in pure bash/script environments
4. **Conservative estimate**: Slightly overestimates rather than underestimates (safer for optimization)

## Alternative Methods

### 1. ctoc Library
- **Accuracy**: 96% (reverse-engineers Claude's actual vocabulary)
- **Implementation**: Python library that approximates Claude's tokenizer
- **Limitation**: Requires Python installation, not suitable for bash-only environments
- **Use when**: Maximum accuracy needed, Python available

### 2. Tool-Based Estimates (Workflow Analyzer)
- **Read tool**: ~500 tokens per invocation (regardless of content size)
- **Grep tool**: ~300 tokens per pattern search
- **Bash tool**: Variable, depends on output length
- **Use when**: Estimating tool call overhead in workflows

### 3. Claude API (Most Accurate)
- **Accuracy**: 100% (uses actual tokenizer)
- **Access**: Not available programmatically within Claude Code (GitHub issues #36678, #34879)
- **Workaround**: Use external script calling Anthropic API with same model
- **Limitation**: Requires API key, network call, not real-time

## Content-Type Variations

| Content Type | Actual chars/token | Estimation Error |
|-------------|-------------------|------------------|
| **English prose** | 3.8–4.2 | ±5% |
| **Code (Python/JS)** | 3.5–4.5 | ±10% |
| **Configuration (JSON/YAML)** | 4.0–4.5 | ±8% |
| **Markdown with code blocks** | 3.7–4.3 | ±7% |
| **Dense symbols (minified JS)** | 2.5–3.5 | ±15% |
| **Non-English text** | 2.0–6.0 | ±20%+ |

## Observer Effect

**Critical consideration**: The context-window-inspector's own SKILL.md adds overhead to the measurement:

- **SKILL.md size**: ~265 lines, ~11.9KB
- **Estimated tokens**: ~2,975 tokens (11,900 chars ÷ 4)
- **Impact**: Inspector reports include its own cost

**Mitigation**: Always note observer effect in reports, subtract inspector's estimated tokens from "wasted tokens" calculations.

## Implementation Patterns

### From config-cleaner agent:
```bash
# Count characters
char_count=$(cat "$file" | wc -c)
# Estimate tokens
est_tokens=$((char_count / 4))
```

### From self-audit skill (Phase 6):
```bash
# Rough estimate: 1 token ≈ 0.75 words, avg 6 chars/word
# Equivalent to chars ÷ 4.5 (slightly more conservative)
```

### From workflow analyzer:
```bash
# Tool call estimates (fixed overhead + content)
read_estimate=500
grep_estimate=300
bash_estimate=1000  # baseline, varies with output
```

## Best Practices for Estimation

1. **Always label as estimates**: Never claim exact token counts
2. **Use consistent formula**: `chars ÷ 4` unless specific reason to deviate
3. **Note error margins**: Include ±10% disclaimer in reports
4. **Prioritize relative comparisons**: "File A is 3× larger than File B" more reliable than absolute counts
5. **Account for observer effect**: Subtract inspector's own token cost from waste calculations
6. **Focus on high-impact items**: ±10% error on 100K token MCP server is 10K tokens — still significant

## External References

- **GitHub Issue #36678**: "No programmatic access to context window contents or token usage"
- **GitHub Issue #34879**: Discussion of token estimation accuracy and MCP overhead
- **ctoc library**: GitHub project for Claude token counting (~96% accuracy)
- **Anthropic Tokenizer Documentation**: Official tokenization guidelines

## Decision Table: When to Use Which Method

| Scenario | Recommended Method | Rationale |
|----------|-------------------|-----------|
| **Quick configuration audit** | `chars ÷ 4` | Fast, no dependencies, conservative estimate |
| **Precise optimization** | ctoc library (if Python available) | 96% accuracy worth setup cost |
| **Workflow analysis** | Tool-based estimates | Captures tool call overhead patterns |
| **External reporting** | Claude API (via separate script) | Maximum accuracy for external stakeholders |
| **Real-time in Claude Code** | `chars ÷ 4` | Only feasible option within constraints |

---

**Key Insight**: The `chars ÷ 4` heuristic is **good enough for optimization decisions**. A 50K token MCP server estimated at 45K or 55K tokens still needs optimization. Focus on **relative sizing** and **clear waste** (missing binaries, duplicate content) rather than absolute precision.