---
name: beads
description: "Use when: tracking work, adding todos, filing bugs, managing tasks/issues, checking what to work on, planning epics, deferring work, pre-PR checks, or any mention of bd/beads. Covers the full bd CLI."
---

# Beads (`bd`) — Skill Reference

**What it is:** Git-native issue tracker (Dolt SQL DB at `.beads/dolt/`). Config committed to git; Dolt data is gitignored. Issue IDs: `<prefix>-<slug>` (e.g. `ko2-tools-abc`).

**bd is the default task tracker.** Any work item that should persist — bugs, features, follow-ups, test gaps — goes into bd, unless the project uses GitHub issues as its primary tracker (in which case bd handles personal/session/cross-project items only). TaskCreate/TaskUpdate is only for managing steps within a single task execution (ephemeral, not persisted).

**Always use `--json` flag** when parsing output programmatically.

---

## Session Startup

```bash
bd prime          # Load workflow context — run at start of every session
bd ready          # Unblocked work (open + no active blockers)
```

`bd ready` is blocker-aware. `bd list --ready` is NOT equivalent.

---

## Quick Capture

```bash
bd q "Fix the thing"                    # Returns just the ID — fastest creation
bd todo add "Small task"                # Lightweight task (type=task, P2)
bd create "Title" -d "details" -t bug -p 0 -l critical
```

`bd q` is for scripting/speed. `bd todo add` for lightweight tasks. `bd create` for full control.

Types: `task` `bug` `feature` `epic` `chore` `decision`
Priority: `0`=critical `1`=high `2`=medium(default) `3`=low `4`=backlog — numeric only, never "high"/"low"

## Read

```bash
bd list                        # Open issues
bd list --all                  # Including closed
bd list -p 1                   # By priority
bd list -l <label>             # By label
bd list --status in_progress
bd show <id>                   # Full detail
bd blocked                     # All blocked issues
bd search <query>              # Text search
bd stale                       # Forgotten issues needing attention
bd query "priority<2 AND status=open"  # Compound filters
bd stats                       # Counts overview
```

## Update

```bash
bd update <id> --claim                    # Atomic: assignee + in_progress (fails if taken)
bd update <id> --status in_progress
bd update <id> --title "..." --priority 1
bd update <id> --append-notes "context"
bd update <id> --add-label foo --remove-label bar
bd comments add <id> "Progress note"      # Add context without changing fields
```

**NEVER use `bd edit`** — opens `$EDITOR`, blocks agents.

## Close & Lifecycle

```bash
bd close <id>                  # Mark done
bd close <id1> <id2> <id3>     # Batch close (preferred)
bd close <id> --reason "text"
bd reopen <id>
bd defer <id>                  # Park for later (hidden from bd ready, visible in bd list)
bd undefer <id>
bd duplicate <id> --of <canonical-id>   # Mark as dupe
bd supersede <old-id> --by <new-id>     # Replace outdated issue
bd todo done <id>              # Shorthand for closing task-type issues
```

## Dependencies

```bash
bd dep add <issue> <depends-on>   # issue depends on depends-on
bd dep <blocker> --blocks <blocked>  # Equivalent, reverse syntax
bd dep tree <id>                  # Visualize dependency chain
bd dep list <id>
```

Direction: `bd dep add A B` → A depends on B → B must close before A unblocks.

## Epics

```bash
bd create "Epic title" -t epic
bd create "Subtask" -t task --parent <epic-id>
bd epic status <epic-id>       # Completion progress
bd children <epic-id>          # List subtasks
```

## Memory (persists across sessions via Dolt)

```bash
bd remember "insight"           # Store cross-session knowledge
bd memories                     # List all
bd memories <keyword>           # Search
bd recall <key>                 # Retrieve
bd forget <key>                 # Delete
```

## Pre-PR & Maintenance

```bash
bd preflight                   # Pre-PR checklist
bd stale                       # Find forgotten issues
bd context                     # Show active repo/backend
```

---

## Common Mistakes

| Wrong | Right |
|-------|-------|
| `bd list --ready` | `bd ready` (blocker-aware) |
| `bd edit <id>` | `bd update <id> --field value` |
| priority `"high"` | priority `1` or `P1` |
| `bd dep add A B` thinking A blocks B | A depends on B (B blocks A) |
| Looking in `.dolt/` | DB is at `.beads/dolt/` |
| MEMORY.md for cross-session insights | `bd remember "..."` |
| TodoWrite for persistent work | `bd create` / `bd q` / `bd todo add` |

---

## Session Close Protocol

```bash
bd close <id1> <id2> ...    # Close all completed issues
bd preflight                # Check for loose ends
```
