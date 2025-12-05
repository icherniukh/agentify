# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This repository manages versioned Claude Code configurations, enabling systematic experimentation with agents, skills, slash commands, MCP servers, and settings. It provides backup/restore capabilities and testing infrastructure to compare configuration effectiveness across different scenarios.

## Architecture Overview

### Configuration Management System

The repo implements a bidirectional sync system between this repository and Claude Code's configuration directories:

- **Global configs** (`~/.claude/`) - Personal settings available across all projects
- **Project configs** (`.claude/` in target projects) - Team-shared or project-specific settings
- **Backup archives** - Timestamped snapshots in `/backups/` for rollback capability

### Testing Infrastructure

The `/testing/` directory contains the evaluation framework for measuring configuration effectiveness:

- **Golden datasets** - Curated input-output pairs for reproducible testing
- **Metrics collection** - Token usage, execution time, success rates, quality scores
- **Benchmarking** - Compare config versions using standardized tasks
- **Observability** - OpenTelemetry instrumentation for deep performance analysis

## Key Commands

### Configuration Management

```bash
# Backup current Claude Code configs to timestamped directory
./scripts/backup.sh

# Deploy configs from this repo to Claude Code
./scripts/deploy.sh [config-name]

# List available config backups/versions
./scripts/list-configs.sh

# Compare two configurations
./scripts/compare.sh <config-a> <config-b>
```

### Testing and Metrics

```bash
# Run test suite against current config
python testing/run_tests.py

# Benchmark a specific agent/skill
python testing/benchmark.py --component <name>

# Compare metrics between two config versions
python testing/compare_metrics.py <config-a> <config-b>

# Generate performance report
python testing/generate_report.py
```

## Repository Structure

```
ccconfig/
├── configs/              # Versioned configuration sets
│   ├── baseline/         # Default/reference configuration
│   ├── experimental/     # Experimental configs being tested
│   └── production/       # Validated, production-ready configs
├── backups/             # Timestamped backup snapshots
│   └── YYYYMMDD_HHMMSS/ # Auto-generated backup directories
├── testing/             # Testing infrastructure
│   ├── golden-datasets/ # Reference test data
│   ├── benchmarks/      # Benchmark task definitions
│   ├── metrics/         # Metrics collection modules
│   └── reports/         # Generated performance reports
├── scripts/             # Management utilities
│   ├── backup.sh        # Backup current configs
│   ├── deploy.sh        # Deploy configs to Claude Code
│   ├── compare.sh       # Compare configurations
│   └── sync.sh          # Bidirectional sync utility
└── docs/                # Documentation
    ├── testing-framework.md  # Complete testing methodology
    └── workflow-guide.md     # Usage workflows
```

## Configuration File Types

This repo manages all Claude Code configuration types:

### 1. Settings Files
- `settings.json` - Team-shared settings (project-level) or global settings
- `settings.local.json` - Personal overrides (never committed to target projects)

### 2. Agents (`.md` files in `agents/`)
Markdown files with YAML frontmatter defining specialized sub-agents

### 3. Skills (directories in `skills/`)
Each skill is a directory containing `SKILL.md` plus optional reference docs and scripts

### 4. Slash Commands (`.md` files in `commands/`)
Prompt templates with optional frontmatter for custom commands

### 5. MCP Server Configurations
Server definitions in `settings.json` or `.mcp.json` for Model Context Protocol integrations

### 6. Hooks (executable scripts in `hooks/`)
Event-driven automation scripts (pre-commit, post-command, etc.)

## Deployment Workflows

### Workflow 1: Safe Experimentation
```bash
# 1. Backup current state before experimenting
./scripts/backup.sh

# 2. Deploy experimental config
./scripts/deploy.sh experimental/new-agent-config

# 3. Test the configuration
python testing/run_tests.py

# 4. If issues found, rollback
./scripts/deploy.sh backups/20251205_143022

# 5. If successful, promote to production
cp -r configs/experimental/new-agent-config configs/production/
```

### Workflow 2: A/B Testing Configurations
```bash
# Run benchmark with config A
./scripts/deploy.sh configs/version-a
python testing/benchmark.py --save-results version-a

# Run benchmark with config B
./scripts/deploy.sh configs/version-b
python testing/benchmark.py --save-results version-b

# Compare results statistically
python testing/compare_metrics.py version-a version-b
```

### Workflow 3: Continuous Integration
```bash
# Automated testing on config changes (in CI/CD)
./scripts/deploy.sh configs/pull-request-123
python testing/run_tests.py --fail-on-regression
python testing/benchmark.py --compare-baseline
```

## Testing Philosophy

### Key Principles
1. **Treat configs as code** - Version control, testing, and deployment rigor
2. **Golden datasets are critical** - Maintain reproducible test scenarios
3. **Measure everything** - Token usage, latency, success rates, quality
4. **Test-driven development** - Write tests before creating new configs
5. **Production capture** - Convert successful interactions into regression tests

### Metrics Categories

**Success Metrics**
- `task_success_rate` - Percentage of tasks completed successfully
- `accuracy_score` - Correctness of outputs vs. expected results
- `first_attempt_success` - Tasks completed without retry/intervention

**Performance Metrics**
- `execution_time` - p50, p95, p99 latencies
- `token_usage` - Input/output tokens per task
- `cost_usd` - Estimated API cost per task

**Reliability Metrics**
- `error_rate` - Percentage of failed executions
- `retry_rate` - How often tasks require retry
- `timeout_rate` - Tasks exceeding time limits

**Quality Metrics** (LLM-as-judge)
- `relevance` - Output addresses the task
- `completeness` - All requirements satisfied
- `code_quality` - Correctness, style, security

## Development Notes

### Creating New Configurations

When creating a new config version:

1. Create directory under `configs/` with descriptive name
2. Include complete `.claude/` structure (settings, agents, skills, commands)
3. Add `README.md` describing the config's purpose and changes
4. Create corresponding golden dataset in `testing/golden-datasets/`
5. Run baseline tests before deployment

### Adding Test Scenarios

New test scenarios should include:

```python
{
  "scenario_id": "unique_identifier",
  "description": "What this tests",
  "component": "agent/skill/command name",
  "inputs": {
    "task": "The user's request",
    "context_files": ["file1.py", "file2.js"],
    "environment": {"working_dir": "/path"}
  },
  "expected_outputs": {
    "success": True,
    "file_changes": [...],
    "quality_criteria": {...}
  }
}
```

### Observability Integration

The testing framework supports OpenTelemetry instrumentation for deep observability:

- Spans track agent/skill execution
- Metrics exported to Prometheus/Grafana
- Structured logs in JSON format
- Integration with Langfuse/AgentOps for LLM-specific observability

## Important Conventions

### Backup Naming
Backups use timestamp format: `YYYYMMDD_HHMMSS` (e.g., `20251205_143022`)

### Config Versioning
Config directories should use semantic naming:
- `baseline` - Reference configuration
- `v1.0`, `v1.1` - Versioned releases
- `exp-<feature>` - Experimental changes
- `prod-<date>` - Production snapshots

### Test Data Versioning
Golden datasets are content-addressed with SHA-256 hashes to detect drift

## Related Documentation

- `/docs/testing-framework.md` - Complete testing methodology
- `/testing/README.md` - Testing infrastructure guide
- Claude Code docs: https://code.claude.com/docs
- OpenTelemetry: https://opentelemetry.io/docs/languages/python/
