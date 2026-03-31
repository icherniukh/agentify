---
name: round
description: Use when transitioning between work sessions and wanting to pick up where the previous session left off.
---

<objective>
Transition between work sessions by reading previous session notes, archiving them, creating a fresh session note, and loading essential context for seamless continuation.
</objective>

<trigger>
User invokes via: /round
</trigger>

<workflow>
## Step 1: Find Latest Session Note

Search for the most recent session note in the project's `.claude-sessions/` directory:

```bash
ls -t .claude-sessions/*.md 2>/dev/null | head -1
```

If no session notes exist, proceed to Step 4 (create new session).

## Step 2: Display Previous Session Summary

Read the latest session note and extract:

- **Status** - Current state of work (look for status indicators, emojis like ⚠️, ✅, ❌)
- **Next Steps** - What was planned to continue
- **Blockers** - Any issues or questions pending
- **Branch** - Git branch if noted

Display a concise summary:

```
📁 Previous session: <filename>

Status: <status>
Next: <next steps>
Blockers: <blockers or "None">
```

## Step 3: Archive Previous Session Note

Rename the previous note with timestamp to preserve it:

```bash
# Get current timestamp
TIMESTAMP=$(date +%H%M%S)
# Rename: 2025-02-19-upload-debug.md → 2025-02-19-upload-debug-142035.md
mv .claude-sessions/<old-file> .claude-sessions/<base>-<timestamp>.md
```

If file already has timestamp, keep as-is.

## Step 4: Create New Session Note

Generate new session note from template:

- **Filename:** `.claude-sessions/YYYY-MM-DD-<topic>.md`
- **Topic:** Extract from previous session or use "continuation"
- **Date:** Current date

Template structure:

```markdown
# Session: <Topic> - <Date>

## Branch
`<current-git-branch>`

## Context
[Loaded from previous session summary]

## Goals This Session
- [ ] <from previous "Next Steps">
- [ ] <additional goals>

## Progress Log
*To be updated during session*

## Blockers / Questions
[Carry over from previous session]

## Notes
*
```

Create `.claude-sessions/` directory if it doesn't exist.

## Step 5: Display Current Context

Gather and display:

1. **Git status:**
   ```bash
   git branch --show-current
   git status --short
   git log --oneline -3
   ```

2. **Key project files** (if they exist):
   - `CLAUDE.md` or `.claude/CLAUDE.md` - Project instructions
   - `AGENTS.md` - Agent guide
   - Any `TODO.md` or `ROADMAP.md`

Display summary:

```
---

🔄 New session: <filename>

Git: <branch> (<X> uncommitted changes)
Recent commits:
  - <commit 1>
  - <commit 2>
  - <commit 3>

Ready to continue.
```

## Step 6: Confirm Session Start

Acknowledge the transition is complete and wait for user direction.

</workflow>

<template_usage>
Use the session note template from `templates/session-note.md`:

1. Copy template content
2. Replace placeholders with actual values
3. Write to `.claude-sessions/YYYY-MM-DD-<topic>.md`
</template_usage>

<error_handling>
- **No previous session:** Skip archive step, create fresh session note with generic template
- **No .claude-sessions directory:** Create it automatically
- **Multiple session notes:** Use most recent by modification time
- **Git not available:** Skip git context, note that git context unavailable
</error_handling>

<success_criteria>
- Previous session note found and summarized (if exists)
- Previous note archived with timestamp (if exists)
- New session note created with proper structure
- Context displayed (git status, recent commits)
- User sees clear summary and knows what to continue
</success_criteria>
