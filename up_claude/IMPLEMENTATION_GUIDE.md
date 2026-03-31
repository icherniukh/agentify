# Implementation Guide: Optimized Task Workflow Convention

**Purpose:** Step-by-step guide to adopt the optimized task workflow convention
**Time Required:** 10-15 minutes
**Applies To:** All projects (globally applicable)

---

## Quick Reference Card

### Before You Start Any Task

```bash
# 1. Create task folder (date first!)
mkdir -p tasks/$(date +%m%d%y)_<codename>_<type>

# 2. Log initial query (REQUIRED!)
# Paste user request verbatim into 00-initial-query.md

# 3. Create task metadata (REQUIRED!)
# Fill in task-metadata.md template

# 4. Update task index
# Add line to tasks/README.md

# 5. Start work
# Create deliverable files (no codename prefix needed)
```

### Task Folder Format
```
/tasks/<date_MMDDYY>_<codename>_<type>/
         ↓          ↓          ↓
      102925    monkey   architecture
```

### File Names Inside Task Folder
```
00-initial-query.md          # REQUIRED: exact user request
task-metadata.md             # REQUIRED: structured info
AgentA-analysis.md           # NO codename prefix
executive-summary.md         # NO codename prefix
phase1-design.md             # NO codename prefix
```

---

## Step-by-Step Setup

### Step 1: Global Installation (5 minutes)

```bash
# Create global conventions directory
mkdir -p ~/.claude/conventions

# Copy optimized convention
cp /Users/ivan/proj/up_claude/TASK_WORKFLOW_CONVENTION_OPTIMIZED.md \
   ~/.claude/conventions/task-workflow.md

# Verify
ls -lh ~/.claude/conventions/task-workflow.md
```

---

### Step 2: Shell Functions (Optional, 5 minutes)

Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Jump to task by codename
task() {
  local codename=$1
  local task_dir=$(find tasks -maxdepth 1 -type d \( -name "*_${codename}_*" -o -name "*_${codename}" \) 2>/dev/null | head -1)
  if [[ -n "$task_dir" ]]; then
    cd "$task_dir" && pwd
  else
    echo "Task not found: $codename"
    echo "Available tasks:"
    ls -1 tasks/ 2>/dev/null | grep -v README | awk -F_ '{print "  " $2}'
  fi
}

# List all tasks with formatting
tasks() {
  if [[ ! -d tasks ]]; then
    echo "No tasks directory found"
    return 1
  fi

  echo "Date     Codename   Type"
  echo "-------  ---------  -------------------"
  ls -1 tasks/ | grep -v README | while read dir; do
    local date=$(echo $dir | cut -d_ -f1)
    local codename=$(echo $dir | cut -d_ -f2)
    local type=$(echo $dir | cut -d_ -f3-)
    printf "%-8s %-10s %s\n" "$date" "$codename" "${type:--}"
  done | sort -r
}

# Create new task with templates
task-new() {
  local codename=$1
  local type=$2

  if [[ -z "$codename" ]]; then
    echo "Usage: task-new <codename> [type]"
    echo "Example: task-new monkey architecture"
    return 1
  fi

  local date=$(date +%m%d%y)
  local folder="tasks/${date}_${codename}"
  [[ -n "$type" ]] && folder="${folder}_${type}"

  if [[ -d "$folder" ]]; then
    echo "Task already exists: $folder"
    return 1
  fi

  mkdir -p "$folder"

  # Create initial query template
  cat > "$folder/00-initial-query.md" <<EOF
# Initial User Query

**Date:** $(date '+%Y-%m-%d %H:%M:%S %Z')
**Session ID:** [if applicable]

## Exact Query

[Paste the exact user request that initiated this task]

## Context Provided

[Any additional context, files referenced, or background information]

## Initial Understanding

[Your interpretation of what needs to be done]
EOF

  # Create task metadata template
  cat > "$folder/task-metadata.md" <<EOF
# Task: $codename - ${type:-Task}

**Codename:** $codename
**Type:** ${type:-Task}
**Created:** $(date '+%Y-%m-%d')
**Status:** Active
**Owner:** [Your name/agent ID]

## Objective

[One paragraph describing what this task aims to accomplish]

## Deliverables

- [ ] [Deliverable 1]
- [ ] [Deliverable 2]
- [ ] [Deliverable 3]

## Outcomes

[To be filled upon completion: what was decided, learned, next steps]

## Dependencies

**Requires:** [tasks this depends on]
**Enables:** [tasks this unblocks]

## Metrics

- Duration: [to be filled]
- Lines of documentation: [to be filled]
- Files modified: [to be filled]
EOF

  echo "✓ Created task: $folder"
  echo ""
  echo "Next steps:"
  echo "  1. Fill in $folder/00-initial-query.md"
  echo "  2. Fill in $folder/task-metadata.md"
  echo "  3. Add task to tasks/README.md"
  echo "  4. cd $folder"
  echo ""
  echo "Or run: task $codename"
}

# Quick task status check
task-status() {
  if [[ ! -d tasks ]]; then
    echo "No tasks directory found"
    return 1
  fi

  echo "=== Task Status Dashboard ==="
  echo ""

  echo "ACTIVE:"
  for dir in tasks/*/; do
    if [[ -f "$dir/task-metadata.md" ]]; then
      local status=$(grep "^**Status:" "$dir/task-metadata.md" | cut -d: -f2 | tr -d ' *')
      if [[ "$status" == "Active" ]]; then
        local codename=$(basename "$dir" | cut -d_ -f2)
        local type=$(basename "$dir" | cut -d_ -f3-)
        printf "  - %s (%s)\n" "$codename" "${type:--}"
      fi
    fi
  done

  echo ""
  echo "BLOCKED:"
  for dir in tasks/*/; do
    if [[ -f "$dir/task-metadata.md" ]]; then
      local status=$(grep "^**Status:" "$dir/task-metadata.md" | cut -d: -f2 | tr -d ' *')
      if [[ "$status" == "Blocked" ]]; then
        local codename=$(basename "$dir" | cut -d_ -f2)
        local type=$(basename "$dir" | cut -d_ -f3-)
        printf "  - %s (%s)\n" "$codename" "${type:--}"
      fi
    fi
  done

  echo ""
  echo "COMPLETE (last 7 days):"
  for dir in tasks/*/; do
    if [[ -f "$dir/task-metadata.md" ]]; then
      local status=$(grep "^**Status:" "$dir/task-metadata.md" | cut -d: -f2 | tr -d ' *')
      local mtime=$(stat -f %m "$dir/task-metadata.md" 2>/dev/null || stat -c %Y "$dir/task-metadata.md" 2>/dev/null)
      local now=$(date +%s)
      local age=$(( (now - mtime) / 86400 ))

      if [[ "$status" == "Complete" ]] && [[ $age -le 7 ]]; then
        local codename=$(basename "$dir" | cut -d_ -f2)
        local type=$(basename "$dir" | cut -d_ -f3-)
        printf "  - %s (%s) - %d days ago\n" "$codename" "${type:--}" "$age"
      fi
    fi
  done
}
```

Then reload:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

**Test:**
```bash
task-new monkey architecture
cd tasks/102925_monkey_architecture
# Should show task folder with templates
```

---

### Step 3: Initialize Project (5 minutes)

In your current project:

```bash
# Create tasks directory
mkdir -p tasks

# Create task index
cat > tasks/README.md <<EOF
# Task Index

## Active Tasks

[Tasks currently being worked on]

## Blocked Tasks

[Tasks waiting on dependencies]

## Recently Completed (Last 30 Days)

[Tasks finished recently]

## Archived

[Older completed tasks - see tasks/archive/]
EOF

# Reference convention in project Claude config
echo "" >> .claude/CLAUDE.md
echo "## Task Workflow Convention" >> .claude/CLAUDE.md
echo "" >> .claude/CLAUDE.md
echo "This project follows the task workflow convention documented in:" >> .claude/CLAUDE.md
echo "\`~/.claude/conventions/task-workflow.md\`" >> .claude/CLAUDE.md
echo "" >> .claude/CLAUDE.md
echo "Quick reference:" >> .claude/CLAUDE.md
echo "- Tasks live in \`/tasks/<date>_<codename>_<type>/\`" >> .claude/CLAUDE.md
echo "- Every task requires \`00-initial-query.md\` and \`task-metadata.md\`" >> .claude/CLAUDE.md
echo "- File names inside task folders have NO codename prefix" >> .claude/CLAUDE.md
echo "- See task index: \`tasks/README.md\`" >> .claude/CLAUDE.md
```

---

## Usage Examples

### Example 1: Create Architecture Review Task

```bash
# 1. Create task
task-new monkey architecture

# 2. Navigate to task
task monkey

# 3. Fill in initial query
cat > 00-initial-query.md <<EOF
# Initial User Query

**Date:** 2025-10-29 14:30:00 UTC

## Exact Query

"Please review the current architecture of the XONE:K2 MIDI translator.
Focus on the threading model, state management, and overall code structure.
Provide recommendations for improvements and alternative approaches."

## Context Provided

- Current codebase has ~8 Python files
- Using asyncio for concurrency
- State management spread across multiple classes
- Some concerns about maintainability
EOF

# 4. Fill in metadata
# Edit task-metadata.md with your details

# 5. Update task index
echo "- **monkey** (102925_monkey_architecture) - Architecture review - Agent C" >> ../README.md

# 6. Start work - create deliverable files
touch AgentA-initial-analysis.md
touch AgentB-specs-review.md
touch AgentC-comprehensive-review.md
```

---

### Example 2: Complete a Task

```bash
# 1. Navigate to task
task monkey

# 2. Update metadata status
# Edit task-metadata.md:
# - Change Status to "Complete"
# - Fill in Outcomes section
# - Add final metrics

# 3. Update task index
# Edit tasks/README.md:
# - Move from "Active Tasks" to "Recently Completed"
# - Add one-line summary

# 4. Set archive date (30-90 days out)
echo "Archive on: $(date -v+60d +%Y-%m-%d)" >> task-metadata.md
```

---

### Example 3: Find Task 3 Months Later

```bash
# List all tasks
tasks
# Output:
# Date     Codename   Type
# -------  ---------  -------------------
# 110525   rocket     performance
# 110125   blitz      hotfix
# 103025   eagle      feature
# 102925   monkey     architecture

# Jump directly to monkey task
task monkey
# Now in: tasks/102925_monkey_architecture/

# Read executive summary
cat executive-summary.md

# Check task outcomes
grep -A 10 "## Outcomes" task-metadata.md
```

---

## Checklist: Creating Your First Task

Use this for your first task to build muscle memory:

- [ ] Run `task-new <codename> <type>`
- [ ] Verify templates created:
  - [ ] `00-initial-query.md` exists
  - [ ] `task-metadata.md` exists
- [ ] Fill in `00-initial-query.md`:
  - [ ] Date and time
  - [ ] Exact user request (verbatim)
  - [ ] Context provided
- [ ] Fill in `task-metadata.md`:
  - [ ] Codename, type, date
  - [ ] Status = "Active"
  - [ ] Owner name
  - [ ] Objective paragraph
  - [ ] Deliverables checklist
- [ ] Update `tasks/README.md`:
  - [ ] Add task to "Active Tasks" section
  - [ ] Format: `- **codename** (date_codename_type) - Description - Owner`
- [ ] Navigate to task:
  - [ ] `task <codename>` works
- [ ] Start creating deliverable files:
  - [ ] NO codename prefix on file names
  - [ ] Use descriptive names: `AgentA-analysis.md`, `design-doc.md`, etc.
- [ ] Complete task:
  - [ ] Update metadata status to "Complete"
  - [ ] Fill in Outcomes section
  - [ ] Add metrics
  - [ ] Update task index (move to "Recently Completed")

---

## Common Mistakes to Avoid

### Mistake 1: Wrong Folder Name Order
```bash
# WRONG
tasks/architecture_102925_monkey/
tasks/monkey_102925_architecture/

# CORRECT
tasks/102925_monkey_architecture/
```

### Mistake 2: Codename in File Names
```bash
# WRONG
tasks/102925_monkey_architecture/
  └── monkey-AgentA-analysis.md

# CORRECT
tasks/102925_monkey_architecture/
  └── AgentA-analysis.md
```

### Mistake 3: Forgetting Initial Query
```bash
# WRONG - missing initial query
tasks/102925_monkey_architecture/
  └── task-metadata.md

# CORRECT
tasks/102925_monkey_architecture/
  ├── 00-initial-query.md      # REQUIRED!
  └── task-metadata.md
```

### Mistake 4: Vague Task Metadata
```bash
# WRONG
Objective: Do some architecture work

# CORRECT
Objective: Review current XONE:K2 architecture focusing on threading model,
state management, and code structure. Provide specific recommendations for
improvements and propose alternative approaches where beneficial.
```

---

## Quick Command Reference

```bash
# Create new task
task-new <codename> [type]

# List all tasks
tasks

# Jump to task
task <codename>

# Check task status
task-status

# Find task files
ls tasks/*_monkey_*/

# Search across task content
grep -r "pattern" tasks/

# Archive old tasks
mv tasks/102925_monkey_architecture tasks/archive/2025-Q4/
```

---

## Validation

After setup, verify everything works:

```bash
# 1. Check global convention exists
ls ~/.claude/conventions/task-workflow.md

# 2. Check shell functions work
task-new test demo
ls tasks/*_test_*/
rm -rf tasks/*_test_*  # cleanup

# 3. Check project has tasks directory
ls tasks/README.md

# 4. Check project references convention
grep "task-workflow" .claude/CLAUDE.md

# All checks pass? You're ready to go!
```

---

## Next Steps

1. **Start your next task using the new convention**
2. **After 3-5 tasks, review:**
   - Is query logging useful?
   - Are metrics providing value?
   - Is structure working well?
3. **Refine as needed:**
   - Adjust metadata fields
   - Add custom shell functions
   - Build tooling if workflow proves valuable

---

## Support

**Convention document:** `~/.claude/conventions/task-workflow.md`
**Analysis document:** `/Users/ivan/proj/up_claude/OPTIMIZATION_ANALYSIS.md`
**This guide:** `/Users/ivan/proj/up_claude/IMPLEMENTATION_GUIDE.md`

**Questions?** Create a task for it:
```bash
task-new improvements workflow
# Document your questions/suggestions
```
