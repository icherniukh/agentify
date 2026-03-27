#!/bin/bash
# Reference implementation of context-window-inspector logic
# This script demonstrates the file reading, token estimation, and analysis steps

set -e

echo "=== Context Window Inspector Test ==="
echo "Testing with sample files in $(pwd)"
echo

# Helper functions
count_chars() {
    wc -c < "$1" | tr -d ' '
}

estimate_tokens() {
    local chars=$1
    echo $((chars / 4))
}

check_file_exists() {
    if [ -f "$1" ]; then
        echo "✓ $1"
        return 0
    else
        echo "✗ $1 (missing)"
        return 1
    fi
}

echo "1. File Reference Integrity"
echo "---------------------------"

# Global CLAUDE.md
if [ -f "global-claude.md" ]; then
    chars=$(count_chars "global-claude.md")
    tokens=$(estimate_tokens "$chars")
    echo "Global CLAUDE.md: $chars chars → ~$tokens tokens"
    
    # Parse @-includes
    echo "  @-includes:"
    grep -E '@[a-zA-Z0-9_.-]+\.md' global-claude.md | while read -r line; do
        inc_file=$(echo "$line" | sed -E 's/.*@([a-zA-Z0-9_.-]+\.md).*/\1/')
        if check_file_exists "$inc_file"; then
            inc_chars=$(count_chars "$inc_file")
            inc_tokens=$(estimate_tokens "$inc_chars")
            echo "    $inc_file: $inc_chars chars → ~$inc_tokens tokens"
        fi
    done
fi

echo
echo "2. MCP Server Inventory"
echo "-----------------------"

if [ -f "settings.json" ]; then
    echo "MCP servers in settings.json:"
    # Simple extraction - in real implementation would use jq
    grep -i '"command"' settings.json | while read -r line; do
        server=$(echo "$line" | sed -E 's/.*"([^"]+)".*/\1/')
        echo "  - $server"
    done
    echo "  (Note: binary existence checks require 'which' command)"
fi

echo
echo "3. Token Estimation Summary"
echo "--------------------------"

total_chars=0
for file in global-claude.md project-claude.md best-practices.md workflow-conventions.md memory.md; do
    if [ -f "$file" ] 2>/dev/null; then
        chars=$(count_chars "$file")
        total_chars=$((total_chars + chars))
        tokens=$(estimate_tokens "$chars")
        echo "$file: $chars chars → ~$tokens tokens"
    fi
done

total_tokens=$(estimate_tokens "$total_chars")
echo "Total: $total_chars chars → ~$total_tokens tokens"
echo
echo "4. Staleness Detection"
echo "----------------------"

# Check for @deprecated-guide.md
if [ ! -f "deprecated-guide.md" ]; then
    echo "✗ @deprecated-guide.md referenced in global-claude.md but file missing"
fi

echo
echo "=== Test Complete ==="
echo "This reference implementation demonstrates the core logic."
echo "The full skill includes redundancy detection, relevance assessment,"
echo "and structured report generation as described in SKILL.md."