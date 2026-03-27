# Session Notes Convention

**Purpose:** Structured session documentation for multi-day work continuity and context recovery.

**Location:** `~/.claude/conventions/session-notes.md`

**Status:** Archived 2026-03-24 — backed up from ~/.claude/conventions/ for potential rehabilitation.
The companion skill (session-notes-writer) is backed up at skills/session-notes-writer/SKILL.md.

---

## The Problem

Multi-session work often loses context:
- User comes back tomorrow: "Continue where we left off"
- Claude checks git: commits don't capture informal decisions, blockers, or next steps
- Claude checks CLAUDE.md: not updated with session-specific details
- Result: User re-explains context, wastes time

**What's missing:** Lightweight session notes capturing informal context between formal commits.

---

## The Solution

**Session notes:** Quick, informal documentation written at end of work sessions to capture:
- What was accomplished this session
- Informal decisions/discoveries not worthy of commit messages
- What to continue next session
- Blockers or open questions

**Stored in:** `.claude-sessions/` directory (dotfile, project-level)

**Used by:** Context recovery protocol when git/CLAUDE.md don't have enough detail

---

## When to Write Session Notes

### Write Session Notes When:

**1. Multi-day work**
- Task spans multiple sessions
- You'll need to pick up context tomorrow/next week
- Example: "Working on architecture refactor over 3 days"

**2. Complex tasks with many moving parts**
- Multiple files changed
- Decisions made that aren't obvious from code
- Example: "Evaluating 3 different CSV parsing approaches"

**3. Blocked or interrupted work**
- Hit a blocker, need to research
- Ran out of time mid-task
- Example: "Need to decide between IOPort and virtual MIDI before continuing"

**4. Handoff scenarios**
- Different Claude agent will continue work
- User will resume with different context
- Example: "User switching from architecture task to implementation"

**5. Discoveries worth noting**
- Found unexpected issues
- Learned project-specific quirks
- Example: "Rekordbox CSV format has two patterns, not one"

### Skip Session Notes When:

**1. Single-session tasks**
- Task completed in one sitting
- Everything committed and documented in CLAUDE.md
- Example: "Fixed typo in README"

**2. Well-documented in git**
- Commit messages capture everything
- No informal decisions to track
- Example: "Added feature X with full test coverage, committed"

**3. Trivial changes**
- Configuration tweaks
- Dependency updates
- Example: "Updated package.json version"

**4. Work already captured elsewhere**
- Detailed task notes in `/tasks/` folder
- Everything in CLAUDE.md already

---

## Folder Structure

### Location
```
project-root/
├── .claude-sessions/      # Session notes directory
│   ├── 2025-12-20-bidirectional-midi.md
│   ├── 2025-12-21-context-recovery.md
│   └── README.md          # Explains purpose for humans
├── .claude/               # Project Claude config
├── tasks/                 # Task-based work
└── [project files]
```

### File Naming
```
.claude-sessions/YYYY-MM-DD-<topic>.md
```

---

## Session Note Template

```markdown
# Session: <Topic> - <Date>

## Summary
[2-3 sentences: What was worked on this session]

## Completed This Session
- [Specific accomplishment 1]
- [Specific accomplishment 2]
- [Commit references if applicable]

## Decisions Made
- [Decision 1 with rationale]
- [Decision 2 with rationale]

## Next Session
- [ ] [Specific task to continue]
- [ ] [Another task]
- [ ] [Follow-up item]

## Blockers / Open Questions
- [Blocker 1: description, potential solutions]
- [Question 1: what needs clarification]

## Notes / Discoveries
- [Informal observation 1]
- [Project quirk discovered]
- [Useful reference link]
```

---

## How Session Notes Fit Context Recovery

From context-recovery search priority:

1. Git history (formal commits)
2. Staged/unstaged changes
3. Project documentation (CLAUDE.md)
4. **Session notes** — Used here when git/docs don't have enough detail
5. Code archaeology
6. Ask user

---

## Related

- **Skill:** `skills/session-notes-writer/SKILL.md` - Automates session note writing
- **Convention:** Context recovery protocol (now in CLAUDE.md, 4-line version)
