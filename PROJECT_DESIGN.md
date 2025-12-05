# Claude Code Configuration Management System - Project Design

## Overview

This repository provides a comprehensive solution for managing, testing, and optimizing Claude Code configurations through version control, automated backup/deployment, and systematic evaluation.

## Core Components

### 1. Configuration Management (`/configs/`, `/backups/`)

**Purpose**: Version-controlled storage of Claude Code configuration sets

**Structure**:
```
configs/
├── baseline/         # Reference configuration
├── experimental/     # Configs under test
└── production/       # Validated configs

backups/
└── YYYYMMDD_HHMMSS/  # Timestamped snapshots
```

**Key Features**:
- Bidirectional sync with `~/.claude/` and project `.claude/` directories
- Timestamped backups for rollback capability
- Semantic versioning for config sets
- Support for all Claude Code config types (agents, skills, commands, MCP servers, settings)

### 2. Deployment Scripts (`/scripts/`)

**Core Scripts**:

#### `backup.sh`
```bash
#!/bin/bash
# Creates timestamped backup of current Claude Code configs
# Usage: ./scripts/backup.sh [--global|--project <path>]

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/$TIMESTAMP"

# Backup global config
cp -r ~/.claude/ "$BACKUP_DIR/global/"

# Backup project configs (optional)
if [ -n "$PROJECT_PATH" ]; then
  cp -r "$PROJECT_PATH/.claude/" "$BACKUP_DIR/project/"
fi

# Create metadata
cat > "$BACKUP_DIR/metadata.json" << JSON
{
  "timestamp": "$TIMESTAMP",
  "source": "global",
  "git_hash": "$(git rev-parse HEAD)",
  "notes": "$NOTES"
}
JSON
```

#### `deploy.sh`
```bash
#!/bin/bash
# Deploys config from repo to Claude Code directories
# Usage: ./scripts/deploy.sh <config-name> [--global|--project <path>]

CONFIG_PATH="configs/$CONFIG_NAME"

# Validate config exists
if [ ! -d "$CONFIG_PATH" ]; then
  echo "Error: Config '$CONFIG_NAME' not found"
  exit 1
fi

# Backup current state first
./scripts/backup.sh --auto

# Deploy to global
if [ "$SCOPE" = "global" ]; then
  rsync -av --delete "$CONFIG_PATH/" ~/.claude/
fi

# Deploy to project
if [ -n "$PROJECT_PATH" ]; then
  rsync -av --delete "$CONFIG_PATH/" "$PROJECT_PATH/.claude/"
fi

# Verify deployment
./scripts/verify.sh "$CONFIG_PATH"
```

#### `compare.sh`
```bash
#!/bin/bash
# Compares two configurations
# Usage: ./scripts/compare.sh <config-a> <config-b>

diff -r "configs/$CONFIG_A" "configs/$CONFIG_B"

# Optionally run performance comparison
if [ "$RUN_BENCHMARKS" = "true" ]; then
  python testing/compare_metrics.py "$CONFIG_A" "$CONFIG_B"
fi
```

### 3. Testing Infrastructure (`/testing/`)

**Testing Framework Components**:

#### Golden Datasets (`/testing/golden-datasets/`)
```
golden-datasets/
├── agents/
│   └── code-reviewer/
│       ├── test_001_simple_pr.json
│       └── test_002_security_issues.json
├── skills/
│   └── python-testing/
│       ├── test_001_pytest_setup.json
│       └── test_002_mock_fixtures.json
└── commands/
    └── optimize/
        └── test_001_performance_refactor.json
```

**Test Scenario Format**:
```json
{
  "scenario_id": "agent_code-reviewer_001",
  "component": "code-reviewer",
  "type": "agent",
  "description": "Review simple pull request",
  "inputs": {
    "task": "Review the changes in this PR",
    "context_files": ["src/auth.py"],
    "file_contents": {
      "src/auth.py": "def login(user, pass): return user == pass"
    }
  },
  "expected_outputs": {
    "success": true,
    "quality_criteria": {
      "identifies_security_issue": true,
      "suggests_bcrypt": true,
      "mentions_plaintext_password": true
    },
    "max_tokens": 2000,
    "max_execution_time": 30
  },
  "metadata": {
    "created": "2025-12-05",
    "difficulty": "easy",
    "tags": ["security", "authentication"]
  }
}
```

#### Test Execution (`/testing/run_tests.py`)
```python
#!/usr/bin/env python3
"""Execute golden dataset tests against current configuration."""

import json
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict
import subprocess
import time

@dataclass
class TestResult:
    scenario_id: str
    success: bool
    execution_time: float
    token_usage: int
    quality_scores: Dict[str, float]
    errors: List[str]

def run_test_scenario(scenario_path: Path) -> TestResult:
    """Execute single test scenario."""
    with open(scenario_path) as f:
        scenario = json.load(f)
    
    # Execute Claude Code with scenario inputs
    start_time = time.time()
    result = execute_claude_code(
        task=scenario['inputs']['task'],
        context=scenario['inputs']['context_files'],
        files=scenario['inputs']['file_contents']
    )
    execution_time = time.time() - start_time
    
    # Evaluate quality
    quality_scores = evaluate_quality(
        result.output,
        scenario['expected_outputs']['quality_criteria']
    )
    
    # Check success criteria
    success = (
        result.error is None and
        result.tokens <= scenario['expected_outputs']['max_tokens'] and
        execution_time <= scenario['expected_outputs']['max_execution_time'] and
        all(score >= 0.7 for score in quality_scores.values())
    )
    
    return TestResult(
        scenario_id=scenario['scenario_id'],
        success=success,
        execution_time=execution_time,
        token_usage=result.tokens,
        quality_scores=quality_scores,
        errors=result.errors
    )

def main():
    """Run all golden dataset tests."""
    test_files = Path('testing/golden-datasets').rglob('*.json')
    results = [run_test_scenario(f) for f in test_files]
    
    # Generate report
    generate_report(results, output='testing/reports/latest.json')
    
    # Exit with failure if any tests failed
    success_rate = sum(r.success for r in results) / len(results)
    print(f"Success Rate: {success_rate:.1%}")
    
    if success_rate < 0.95:  # 95% threshold
        exit(1)
```

#### Metrics Collection (`/testing/metrics/`)
```python
from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider

class ConfigMetricsCollector:
    """Collect performance and quality metrics."""
    
    def __init__(self):
        self.tracer = trace.get_tracer(__name__)
        self.meter = metrics.get_meter(__name__)
        
        # Define metrics
        self.task_duration = self.meter.create_histogram(
            "claude.task.duration",
            description="Task execution time in seconds"
        )
        self.token_usage = self.meter.create_counter(
            "claude.tokens.total",
            description="Total tokens used"
        )
        self.success_counter = self.meter.create_counter(
            "claude.tasks.success",
            description="Successful task completions"
        )
    
    def record_execution(self, component: str, task: str, result: dict):
        """Record metrics for a single execution."""
        with self.tracer.start_as_current_span("claude_task") as span:
            span.set_attribute("component", component)
            span.set_attribute("task_type", task)
            
            self.task_duration.record(
                result['execution_time'],
                {"component": component}
            )
            self.token_usage.add(
                result['tokens'],
                {"component": component, "type": "total"}
            )
            if result['success']:
                self.success_counter.add(1, {"component": component})
```

#### Benchmark Suite (`/testing/benchmarks/`)
```python
"""Standard benchmark tasks for config comparison."""

BENCHMARK_SUITE = {
    "code_generation": [
        {
            "id": "gen_001",
            "task": "Implement binary search in Python with type hints",
            "expected_features": ["type_hints", "docstring", "edge_cases"],
            "max_tokens": 500
        },
        {
            "id": "gen_002", 
            "task": "Create React component for user profile card",
            "expected_features": ["typescript", "props_interface", "styling"],
            "max_tokens": 800
        }
    ],
    "debugging": [
        {
            "id": "debug_001",
            "task": "Find and fix the bug in this authentication logic",
            "context_files": ["auth.py"],
            "expected_fixes": ["bcrypt", "timing_attack"],
            "max_tokens": 1000
        }
    ],
    "refactoring": [
        {
            "id": "refactor_001",
            "task": "Refactor this function to reduce complexity",
            "context_files": ["legacy.py"],
            "expected_improvements": ["extract_method", "reduce_nesting"],
            "max_tokens": 1500
        }
    ]
}
```

### 4. Observability & Analytics (`/testing/observability/`)

**OpenTelemetry Integration**:
```python
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

def setup_observability():
    """Configure OpenTelemetry for Claude Code."""
    # Set up tracer
    provider = TracerProvider()
    processor = BatchSpanProcessor(OTLPSpanExporter(
        endpoint="http://localhost:4317"
    ))
    provider.add_span_processor(processor)
    trace.set_tracer_provider(provider)
    
    # Instrument Claude Code execution
    return trace.get_tracer("claude_code_config")
```

**Langfuse Integration**:
```python
from langfuse import Langfuse

langfuse = Langfuse(
    public_key="pk-...",
    secret_key="sk-..."
)

# Trace agent execution
trace = langfuse.trace(
    name="code-review-agent",
    metadata={"config_version": "v1.2"}
)

# Track LLM calls
generation = trace.generation(
    name="review_analysis",
    model="claude-sonnet-4-5",
    input="Review this code...",
    output="The code has these issues...",
    usage={
        "input_tokens": 1500,
        "output_tokens": 800
    }
)
```

## Workflow Scenarios

### Scenario 1: Daily Experimentation

```bash
# Morning: Backup current config
./scripts/backup.sh --notes "Before testing new agent"

# Create experimental config
cp -r configs/baseline configs/experimental/new-code-reviewer
# ... edit agents/code-reviewer.md ...

# Deploy and test
./scripts/deploy.sh experimental/new-code-reviewer
python testing/run_tests.py --component code-reviewer

# If good: promote to production
# If bad: rollback
./scripts/deploy.sh backups/20251205_090000
```

### Scenario 2: A/B Testing

```bash
# Test config A
./scripts/deploy.sh configs/version-a
python testing/benchmark.py --save version-a

# Test config B  
./scripts/deploy.sh configs/version-b
python testing/benchmark.py --save version-b

# Statistical comparison
python testing/compare_metrics.py version-a version-b
# Output: Config B shows 15% improvement in success rate (p<0.05)
```

### Scenario 3: Project-Specific Deployment

```bash
# Deploy specific config to a project
./scripts/deploy.sh production/python-dev \
  --project ~/projects/my-app

# Verify it works
cd ~/projects/my-app
# ... test Claude Code with project context ...

# Commit to project repo
git add .claude/
git commit -m "Add Python dev Claude Code config"
```

## Implementation Phases

### Phase 1: Core Infrastructure (Week 1)
- [ ] Create repository structure
- [ ] Implement backup.sh script
- [ ] Implement deploy.sh script
- [ ] Basic verification script
- [ ] Git workflow setup

### Phase 2: Testing Foundation (Week 2)
- [ ] Golden dataset structure
- [ ] Create 10 baseline test scenarios
- [ ] Basic test runner (run_tests.py)
- [ ] Simple quality evaluation
- [ ] Success/failure reporting

### Phase 3: Metrics & Observability (Week 3-4)
- [ ] OpenTelemetry instrumentation
- [ ] Metrics collection module
- [ ] Langfuse integration
- [ ] Dashboard setup (Grafana)
- [ ] Performance tracking database

### Phase 4: Advanced Testing (Week 5-6)
- [ ] Benchmark suite creation
- [ ] LLM-as-judge quality evaluation
- [ ] A/B testing framework
- [ ] Statistical comparison tools
- [ ] Regression detection

### Phase 5: Automation & CI/CD (Week 7-8)
- [ ] GitHub Actions workflows
- [ ] Automated testing on PR
- [ ] Performance regression alerts
- [ ] Scheduled benchmark runs
- [ ] Report generation automation

## Technology Stack

**Core Tools**:
- Shell scripts (bash) - Deployment automation
- Python 3.11+ - Testing framework
- Git - Version control
- OpenTelemetry - Observability
- Pytest - Test execution

**Observability Stack**:
- Langfuse - LLM-specific observability
- Prometheus - Metrics storage
- Grafana - Visualization
- SQLite - Local analytics DB

**Testing Tools**:
- pytest - Test framework
- DeepEval - LLM evaluation
- promptfoo - Prompt testing (optional)

## Success Metrics

**Project Success Criteria**:
1. Can safely experiment with configs and rollback within 30 seconds
2. 95%+ success rate on golden dataset tests
3. Automated detection of performance regressions
4. Statistical confidence in A/B test comparisons
5. Complete observability of config performance in production

**Key Performance Indicators**:
- Time to deploy config: < 1 minute
- Time to rollback: < 30 seconds
- Test suite execution: < 5 minutes
- Benchmark suite: < 15 minutes
- Config comparison report generation: < 2 minutes

## Next Steps

1. **Immediate**: Create directory structure and initial backup script
2. **Day 1**: Implement deploy.sh with safety checks
3. **Day 2-3**: Create first 10 golden dataset scenarios
4. **Week 1**: Complete basic testing infrastructure
5. **Week 2**: Add metrics collection and observability
6. **Week 3+**: Build advanced features (A/B testing, automation)

## References

- Testing Framework: `/tasks/120525_testing_methodology/comprehensive-testing-framework.md`
- Claude Code Docs: https://code.claude.com/docs
- OpenTelemetry Python: https://opentelemetry.io/docs/languages/python/
- Langfuse: https://langfuse.com/docs
