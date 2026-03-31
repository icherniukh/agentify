---
name: git-context-recovery
description: Use when user references previous work phases, tasks, or discussions from prior sessions not present in current conversation context.
---

# Git Context Recovery

This skill automatically searches git history to recover context when you reference previous work that isn't in the current session memory.

## When This Skill Activates

This skill detects when you reference previous work context:

**Trigger phrases:**
- "phases 1-2 complete", "phase 3 pending"
- "continue where we left off"
- "pick up from yesterday"
- "as I/we discussed before"
- "the task we talked about"
- "resume the work on X"
- "what was the status of Y?"

**What it does:**
Instead of asking you to clarify or searching in wrong places, Claude will immediately:
1. Check git commit history for work documentation
2. Inspect recent code changes
3. Read project documentation
4. Only ask for clarification if nothing is found

## The Problem This Solves

**Before this skill:**
- Claude searches task docs, session notes, greps for keywords
- Wastes 2000-3000 tokens on futile searching
- Forces you to re-explain context already documented in commits
- Frustrating multi-turn clarification conversations

**With this skill:**
- Git history checked first (commits often document phases/progress)
- Context recovered in 100-200 tokens
- Net savings: ~1800-2800 tokens per incident
- User doesn't repeat themselves

## How It Works

When triggered, Claude follows this search priority:

### Priority 1: Git History (Recent Work Context)
```bash
# Check last 10 commits
git log --oneline -10

# Read latest commit message in detail
git show HEAD

# If commit references the topic, show full commit
git show <relevant-commit-hash>
```

**What to look for:**
- WIP commits with phase documentation
- Commit messages with TODO lists
- "Phase X Complete, Remaining:" patterns
- Recent feature additions matching user's reference

### Priority 2: Staged/Unstaged Changes (Current WIP)
```bash
git status
git diff          # Unstaged changes
git diff --staged # Staged changes
git diff HEAD~3..HEAD --stat  # Recent file changes
```

### Priority 3: Project Documentation
```bash
# Check CLAUDE.md "Pending Work" section
# Check latest task folder
# Check /docs/, /refs/ directories
# Read task-metadata.md if exists
```

### Priority 4: Session Notes (if .claude-sessions exists)

**Why fourth:** Session-specific context for multi-day work. Captures informal decisions not in commits.

```bash
ls -lt .claude-sessions/ | head -3
# Read most recent session note
```

**What to look for:**
- Session summaries with work status
- "Next Session" sections with continuation tasks
- Informal decisions not in git/CLAUDE.md

### Priority 5: Code Archaeology
```bash
grep -rn "TODO\|FIXME\|Phase\|Step" <relevant-files>
```

### Priority 6: Ask User (Only if above yields nothing)
"I checked git history (last 10 commits), recent changes, and project docs but couldn't find context for [X]. Could you clarify what you're referring to?"

## Example Usage

**User:** "Phases 1-2 complete, 3-4 TBD"

**Claude (with this skill):**
```bash
# Immediately runs:
git log --oneline -5
# Sees: "4fb223a WIP: Add bidirectional MIDI..."

git show 4fb223a
# Finds commit message:
# "Phase 1 & 2 Complete:
#  - IOPort support with graceful fallback
#  - Grouping infrastructure
#  Remaining:
#  - Phase 3: Rewrite print_message()
#  - Phase 4: Add CLI flags"
```

**Claude responds:**
"Found context in commit 4fb223a:
- Phase 1: IOPort support - Complete
- Phase 2: Grouping infrastructure - Complete
- Phase 3: Throttled display updates - Pending
- Phase 4: CLI flags and Ctrl+C handling - Pending

Ready to start Phase 3. Should I proceed with rewriting print_message()?"

## Instructions

When user references previous work context that isn't in current session memory:

### Step 1: Detect Context Gap
Recognize trigger phrases or situations where user expects Claude to know something from prior work.

### Step 2: Check Git History FIRST
```bash
# Read recent commits
git log --oneline -10

# Show latest commit in detail
git show HEAD

# If user mentioned specific topic/phase, search commit messages
git log --all --grep="Phase\|TODO\|WIP" --oneline -20
```

### Step 3: Inspect Recent Changes
```bash
# See what files changed recently
git diff HEAD~5..HEAD --stat

# Read actual changes in relevant files
git diff HEAD~5..HEAD <file>
```

### Step 4: Check Session Notes (If git yields nothing)
```bash
ls -lt .claude-sessions/ | head -3
# Read most recent session note
```

### Step 5: Check Project Docs
- Read CLAUDE.md "Pending Work" section
- Check `/tasks/`, `/docs/`, `/refs/` directories for latest work
- Read `task-metadata.md` if exists

### Step 6: Code Archaeology (If still unclear)
```bash
# Search for phase markers, TODOs in code
grep -rn "Phase\|TODO\|FIXME\|Step" <relevant-files>
```

### Step 7: Ask User (Only as last resort)
State what you searched and what you didn't find:

"I checked:
- Last 10 git commits
- Recent file changes (git diff)
- Project CLAUDE.md, tasks/docs/refs directories
- Session notes in .claude-sessions/
- Code TODOs and phase markers

Couldn't find context for '[user's reference]'. Could you clarify what work you're referring to?"

## Benefits

**Token efficiency:**
- Avoids 2000-3000 token searches in wrong places
- Git check costs ~100-200 tokens
- Net savings: ~1800-2800 tokens per context recovery

**User experience:**
- No frustrating re-explanations of documented work
- Claude picks up exactly where work left off
- Git commits are already authoritative source

**Code quality:**
- Encourages documenting phases/progress in commits
- Git history becomes first-class context source
- Aligns with how developers naturally work

## Best Practices

**For users:**
- Document work phases in commit messages
- Use WIP commits with "Phase X Complete, Remaining:" format
- Keep CLAUDE.md "Pending Work" section updated

**For Claude:**
- Always check git BEFORE asking user for clarification
- Read commit messages fully (not just titles)
- Look at code changes, not just commit messages
- Summarize what was found concisely

## Related Conventions

- `~/.claude/conventions/context-recovery.md` - Full search priority protocol
- `~/.claude/conventions/session-notes.md` - Session note structure for multi-day work
- `~/.claude/conventions/task-workflow.md` - Task organization patterns
- Project CLAUDE.md - Project-specific phase tracking conventions

---

**This skill makes git history a first-class context source alongside project documentation.**
