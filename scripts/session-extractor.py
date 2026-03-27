#!/usr/bin/env python3
import json
import os
import sys
import glob
from collections import defaultdict
from datetime import datetime, timedelta
import argparse


def analyze_sessions(days_back=7, limit=30, project=None):
    base_dir = os.path.expanduser("~/.claude/projects")

    if project:
        search_path = os.path.join(base_dir, f"*{project}*", "*.jsonl")
    else:
        search_path = os.path.join(base_dir, "*", "*.jsonl")

    jsonl_files = glob.glob(search_path)
    jsonl_files.sort(key=os.path.getmtime, reverse=True)

    cutoff_date = datetime.now() - timedelta(days=days_back)

    stats = {
        "metadata": {
            "period_days": days_back,
            "sessions_analyzed": 0,
            "files_scanned": len(jsonl_files),
        },
        "totals": {
            "turns": 0,
            "input_tokens": 0,
            "cache_creation_tokens": 0,
            "cache_read_tokens": 0,
            "output_tokens": 0,
            "total_tokens": 0,
        },
        "tools": defaultdict(int),
        "tool_errors": defaultdict(int),
        "skills_invoked": defaultdict(int),
        "agents_invoked": defaultdict(int),
    }

    files_processed = 0

    for file_path in jsonl_files:
        if files_processed >= limit:
            break

        mtime = datetime.fromtimestamp(os.path.getmtime(file_path))
        if mtime < cutoff_date:
            continue

        files_processed += 1
        stats["metadata"]["sessions_analyzed"] += 1

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                for line in f:
                    if not line.strip():
                        continue

                    try:
                        entry = json.loads(line)
                    except json.JSONDecodeError:
                        continue

                    entry_type = entry.get("type")

                    if entry_type == "assistant":
                        msg = entry.get("message", {})

                        usage = msg.get("usage", {})
                        if usage:
                            stats["totals"]["input_tokens"] += usage.get(
                                "input_tokens", 0
                            )
                            stats["totals"]["output_tokens"] += usage.get(
                                "output_tokens", 0
                            )
                            stats["totals"]["cache_creation_tokens"] += usage.get(
                                "cache_creation_input_tokens", 0
                            )
                            stats["totals"]["cache_read_tokens"] += usage.get(
                                "cache_read_input_tokens", 0
                            )
                            stats["totals"]["turns"] += 1

                        content = msg.get("content", [])
                        if isinstance(content, list):
                            for block in content:
                                if block.get("type") == "tool_use":
                                    tool_name = block.get("name", "unknown")
                                    stats["tools"][tool_name] += 1

                                    if tool_name == "Skill":
                                        skill_name = block.get("input", {}).get(
                                            "skill"
                                        ) or block.get("input", {}).get("name")
                                        if skill_name:
                                            stats["skills_invoked"][skill_name] += 1
                                    elif tool_name in ["Agent", "Task", "task"]:
                                        agent_name = (
                                            block.get("input", {}).get("subagent_type")
                                            or block.get("input", {}).get("agent")
                                            or block.get("input", {}).get("name")
                                        )
                                        if agent_name:
                                            stats["agents_invoked"][agent_name] += 1

                    elif entry_type == "user":
                        msg = entry.get("message", {})
                        content = msg.get("content", [])
                        if isinstance(content, list):
                            for block in content:
                                if block.get("type") == "tool_result":
                                    if block.get("is_error", False):
                                        stats["tool_errors"]["total"] += 1

        except Exception as e:
            print(f"Error reading {file_path}: {e}", file=sys.stderr)

    stats["totals"]["total_tokens"] = (
        stats["totals"]["input_tokens"]
        + stats["totals"]["output_tokens"]
        + stats["totals"]["cache_creation_tokens"]
        + stats["totals"]["cache_read_tokens"]
    )

    return stats


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract Claude Code session stats")
    parser.add_argument("--days", type=int, default=7, help="Days back to scan")
    parser.add_argument("--limit", type=int, default=30, help="Max sessions to analyze")
    parser.add_argument(
        "--project", type=str, default=None, help="Filter by project name"
    )
    parser.add_argument("--out", type=str, default=None, help="Output JSON file path")

    args = parser.parse_args()

    result = analyze_sessions(
        days_back=args.days, limit=args.limit, project=args.project
    )

    result["tools"] = dict(result["tools"])
    result["tool_errors"] = dict(result["tool_errors"])
    result["skills_invoked"] = dict(result["skills_invoked"])
    result["agents_invoked"] = dict(result["agents_invoked"])

    json_output = json.dumps(result, indent=2)

    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            f.write(json_output)
        print(f"Analysis saved to {args.out}")
    else:
        print(json_output)
