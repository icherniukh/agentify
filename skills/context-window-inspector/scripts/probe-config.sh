#!/bin/bash
# Environment probe for context-window-inspector
# Detects available tools, Python environment, and estimation capabilities

set -e

echo "=== Context Window Inspector Environment Probe ==="
echo "Run date: $(date)"
echo ""

# 1. Basic system info
echo "## System Information"
echo "- Hostname: $(hostname 2>/dev/null || echo 'unknown')"
echo "- OS: $(uname -s) $(uname -r)"
echo "- Shell: $SHELL"
echo ""

# 2. Claude Code directories
echo "## Claude Code Directories"
if [ -d "$HOME/.claude" ]; then
    echo "- ~/.claude: EXISTS ($(du -sh "$HOME/.claude" | cut -f1))"
    if [ -f "$HOME/.claude/CLAUDE.md" ]; then
        claude_size=$(wc -c < "$HOME/.claude/CLAUDE.md")
        echo "  - CLAUDE.md: $claude_size bytes (~$((claude_size / 4)) estimated tokens)"
    else
        echo "  - CLAUDE.md: NOT FOUND"
    fi
else
    echo "- ~/.claude: NOT FOUND"
fi

if [ -f ".claude/CLAUDE.md" ]; then
    proj_size=$(wc -c < ".claude/CLAUDE.md")
    echo "- ./.claude/CLAUDE.md: $proj_size bytes (~$((proj_size / 4)) estimated tokens)"
elif [ -f "./CLAUDE.md" ]; then
    proj_size=$(wc -c < "./CLAUDE.md")
    echo "- ./CLAUDE.md: $proj_size bytes (~$((proj_size / 4)) estimated tokens)"
else
    echo "- Project CLAUDE.md: NOT FOUND"
fi
echo ""

# 3. Required tool detection
echo "## Required Tools"
REQUIRED_TOOLS=("cat" "wc" "grep" "find" "test" "which")
MISSING_TOOLS=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "- $tool: FOUND ($(which "$tool"))"
    else
        echo "- $tool: MISSING"
        MISSING_TOOLS+=("$tool")
    fi
done
echo ""

# 4. Optional tools detection
echo "## Optional Tools"
OPTIONAL_TOOLS=("jq" "python3" "python" "bash" "zsh" "fish")

for tool in "${OPTIONAL_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        location=$(which "$tool")
        if [ "$tool" = "jq" ]; then
            echo "- jq: FOUND ($location) - JSON parsing available"
        elif [[ "$tool" == python* ]]; then
            version=$("$tool" --version 2>/dev/null | head -1 || echo "unknown")
            echo "- $tool: FOUND ($location) - $version"
            # Check for ctoc
            if "$tool" -c "import ctoc" 2>/dev/null; then
                echo "  - ctoc library: INSTALLED (96% token accuracy)"
            else
                echo "  - ctoc library: NOT INSTALLED (using chars÷4 heuristic)"
            fi
        else
            echo "- $tool: FOUND ($location)"
        fi
    else
        echo "- $tool: NOT FOUND"
    fi
done
echo ""

# 5. MCP server detection
echo "## MCP Server Configuration"
MCP_FILES=("$HOME/.claude/settings.json" "$HOME/.claude/.mcp.json")

for mcp_file in "${MCP_FILES[@]}"; do
    if [ -f "$mcp_file" ]; then
        echo "- $mcp_file: EXISTS"
        if command -v jq >/dev/null 2>&1; then
            server_count=$(jq '.mcpServers | length' "$mcp_file" 2>/dev/null || echo "0")
            echo "  - MCP servers configured: $server_count"
            
            # Check for missing binaries
            if [ "$server_count" -gt 0 ]; then
                echo "  - Server binary checks:"
                jq -r '.mcpServers | to_entries[] | .key + "::" + (.value.command // .value)' "$mcp_file" 2>/dev/null | while IFS="::" read -r name command; do
                    # Extract first word from command (binary name)
                    binary=$(echo "$command" | awk '{print $1}')
                    if command -v "$binary" >/dev/null 2>&1; then
                        echo "    - $name: FOUND ($(which "$binary"))"
                    else
                        echo "    - $name: MISSING ($binary not on PATH)"
                    fi
                done
            fi
        else
            echo "  - (jq not available for detailed analysis)"
        fi
    else
        echo "- $mcp_file: NOT FOUND"
    fi
done
echo ""

# 6. Memory index check
echo "## Memory Index"
MEMORY_FILES=("$HOME/.claude/MEMORY.md" "./MEMORY.md" ".claude/MEMORY.md")

found_memory=""
for mem_file in "${MEMORY_FILES[@]}"; do
    if [ -f "$mem_file" ]; then
        lines=$(wc -l < "$mem_file")
        size=$(wc -c < "$mem_file")
        echo "- $mem_file: $lines lines, $size bytes (~$((size / 4)) estimated tokens)"
        found_memory="yes"
    fi
done

if [ -z "$found_memory" ]; then
    echo "- No MEMORY.md files found"
fi
echo ""

# 7. @-include pattern check
echo "## @-Include Pattern Detection"
if [ -f "$HOME/.claude/CLAUDE.md" ]; then
    include_count=$(grep -c -E '@[a-zA-Z0-9_.-]+\.md' "$HOME/.claude/CLAUDE.md" || echo "0")
    echo "- Global CLAUDE.md: $include_count @-include pattern(s)"
    
    if [ "$include_count" -gt 0 ]; then
        echo "  - Included files:"
        grep -o -E '@[a-zA-Z0-9_.-]+\.md' "$HOME/.claude/CLAUDE.md" | while read -r inc; do
            inc_file="${inc#@}"
            inc_path="$HOME/.claude/$inc_file"
            if [ -f "$inc_path" ]; then
                inc_size=$(wc -c < "$inc_path")
                echo "    - $inc: EXISTS ($inc_size bytes)"
            else
                echo "    - $inc: MISSING"
            fi
        done
    fi
fi
echo ""

# 8. Summary
echo "## Probe Summary"
echo "- Required tools missing: ${#MISSING_TOOLS[@]}"
if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "  - Missing: ${MISSING_TOOLS[*]}"
    echo "  - WARNING: Some core functionality may be limited"
fi

echo "- Token estimation method:"
if python3 -c "import ctoc" 2>/dev/null; then
    echo "  - PRIMARY: ctoc library (96% accuracy)"
    echo "  - FALLBACK: chars ÷ 4 heuristic"
else
    echo "  - PRIMARY: chars ÷ 4 heuristic (±10-15% accuracy)"
    echo "  - RECOMMEND: pip install ctoc for better accuracy"
fi

echo "- Environment: $(uname -s) with $(command -v bash || echo 'unknown shell')"
echo "- Claude Code config: $(if [ -d "$HOME/.claude" ]; then echo "DETECTED"; else echo "NOT DETECTED"; fi)"
echo ""

echo "=== Probe Complete ==="
echo "Use this information to tailor context window analysis."
echo "For accurate token counts, install: pip install ctoc"
echo "For missing tools, install via system package manager."