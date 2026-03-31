---
name: session-notes-writer
description: Proactively suggests and writes session notes at end of work sessions for multi-day task continuity
---

# Session Notes Writer

This skill teaches Claude to **proactively write session notes** at the end of complex work sessions to enable seamless continuation in future sessions.

## When This Skill Activates

### Trigger Scenarios

**1. End of work session (user signals)**
- "I need to stop here"
- "Let's wrap up for today"
- "Pause this work, I'll continue tomorrow"
- "That's all for now"

**2. Work left incomplete**
- Task is partially done
- Hit a blocker mid-work
- Ran out of time
- Waiting for user input/decision

**3. Complex multi-session work**
- Architecture changes spanning days
- Research spikes with findings
- Refactors touching many files
- Feature implementations with phases

### When NOT to Activate

**Skip session notes for:**
- Trivial tasks (typo fixes, config tweaks)
- Single-session tasks completed fully
- Work already fully documented in git commits
- User explicitly says "don't write session note"

---

## The Problem This Solves

**Before this skill:**
- Claude forgets to suggest session notes
- User starts next session: "Where were we?"
- Context recovery takes extra time
- Informal decisions are lost

**With this skill:**
- Claude proactively offers: "Should I write a session note for continuity?"
- User confirms
- Claude generates structured note
- Next session: Claude checks session note, picks up seamlessly

---

## How It Works

### Decision Logic: Should We Write a Session Note?

When user signals end of session, evaluate:

```
IF (task incomplete OR multi-day work OR blocker encountered)
   AND (NOT trivial change)
   AND (NOT fully documented in git/CLAUDE.md)
THEN
   Suggest: "Should I write a session note for when you continue this work?"
```

**Factors to consider:**

**✅ Write session note IF:**
- Multiple files modified across session
- Made informal decisions not captured in commits
- Hit blockers or open questions
- User said "I'll continue tomorrow"
- Complex task with phases (some complete, some pending)

**❌ Skip session note IF:**
- Single file, single commit, fully documented
- Trivial change (version bump, typo fix)
- User said "we're done with this task"
- Everything captured in git commit messages already

---

## Instructions

### Step 1: Detect End of Session

Watch for signals:
- User says "wrap up", "stop here", "continue tomorrow"
- You completed work but user didn't ask to continue
- Hit blocker and paused work
- User hasn't responded in a while (may be stepping away)

### Step 2: Evaluate Session Complexity

Ask yourself:
- Was this a complex, multi-file change?
- Did we make decisions that aren't obvious from code?
- Is this part of a larger multi-day effort?
- Would future Claude benefit from notes about what we did?

### Step 3: Suggest Session Note (If Appropriate)

**Offer proactively:**
```
"This looks like a good stopping point. Should I write a session note
capturing what we completed and what to continue next session? This
will help pick up the work seamlessly tomorrow."
```

**If user confirms, proceed to Step 4.**

**If user declines, respect it:**
```
User: "No need, I've got it"
Claude: "Understood. Feel free to ask if you change your mind."
```

### Step 4: Generate Session Note

**Gather context:**
- What was accomplished this session?
- What files changed? (check `git status`, `git diff --stat`)
- What decisions were made?
- What should continue next session?
- Any blockers or open questions?

**Create `.claude-sessions/` directory if needed:**
```bash
mkdir -p .claude-sessions
```

**Generate filename:**
```
.claude-sessions/YYYY-MM-DD-<topic>.md
```

**Use template from session-notes convention:**
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

**Write the file:**
```bash
# Use Write tool to create session note
```

### Step 5: Confirm and Summarize

Tell user what you created:
```
"Session note written to .claude-sessions/2025-12-21-context-recovery.md

Summary:
- Completed: git-context-recovery skill, context-recovery convention
- Next session: Create session-notes-writer skill, enhance lessons-learned
- No blockers

This will help us pick up exactly where we left off next time."
```

---

## Example Usage

### Example 1: Multi-Day Refactor Session

**User:** "I need to stop here, I'll continue tomorrow"

**Claude evaluates:**
- Complex work: Refactored sniffer.py into 3 modules
- Partially complete: csv_parser and monitor done, cli.py pending
- Informal decision: Chose Click over argparse for CLI
- Multi-day: User explicitly said "continue tomorrow"

**Verdict:** Write session note

**Claude suggests:**
```
"This looks like a good stopping point. Should I write a session note
capturing what we completed (csv_parser, monitor modules) and what to
continue tomorrow (cli.py with Click)?"
```

**User:** "Yes please"

**Claude writes:**
`.claude-sessions/2025-12-18-modular-refactor.md`
```markdown
# Session: Modular Architecture Refactor - 2025-12-18

## Summary
Refactored monolithic sniffer.py into modular structure. Created csv_parser.py and monitor.py with core classes. CLI migration pending.

## Completed This Session
- Created csv_parser.py with RekordboxCSVParser class
- Created monitor.py with RekordboxMIDISniffer class
- Updated imports in sniffer.py
- All existing functionality preserved

## Decisions Made
- **Use Click for CLI instead of argparse**
  - Rationale: Better UX, cleaner command structure, used in modern Python CLIs
  - Reference: https://click.palletsprojects.com/

## Next Session
- [ ] Create cli.py with Click command structure
- [ ] Migrate all CLI commands from sniffer.py
- [ ] Update tests to import from new modules
- [ ] Update CLAUDE.md with new architecture

## Blockers / Open Questions
- None currently

## Notes / Discoveries
- Separation makes testing much easier (can mock CSV parser independently)
- monitor.py is ~200 lines, good size for a focused module
```

**Claude confirms:**
```
"Session note written to .claude-sessions/2025-12-18-modular-refactor.md
Tomorrow we'll pick up with creating cli.py using Click."
```

---

### Example 2: Research Spike with Blocker

**Context:** Claude spent session researching bidirectional MIDI monitoring, hit technical blocker.

**User:** "This is getting complex, let's pause and think about it"

**Claude evaluates:**
- Research session with findings
- Hit blocker (standard MIDI can't do bidirectional capture)
- Important discoveries (IOPort limitations, CoreMIDI architecture)
- User wants to pause and reconsider approach

**Verdict:** Write session note

**Claude suggests:**
```
"Good idea to pause. Should I write a session note capturing what we
learned about bidirectional monitoring and the technical limitations we
discovered? This will help us make an informed decision next session."
```

**User:** "Yes, that'd be helpful"

**Claude writes:**
`.claude-sessions/2025-12-19-bidirectional-research.md`
```markdown
# Session: Bidirectional MIDI Monitoring - 2025-12-19

## Summary
Researched bidirectional MIDI monitoring for capturing Rekordbox→controller LED feedback. Discovered standard mido/rtmidi cannot capture these messages due to macOS CoreMIDI architecture.

## Completed This Session
- Analyzed mido and rtmidi source code for monitoring capabilities
- Tested IOPort for bidirectional capture (unsuccessful)
- Researched CoreMIDI spy techniques and virtual through-ports
- Documented findings in tasks/121925_bidirectional_research/

## Decisions Made
- **Not implementing bidirectional in Phase 1**
  - Rationale: Requires custom CoreMIDI driver or complex virtual port architecture
  - Complexity doesn't justify benefit for current use case
  - Controller→computer monitoring (IOPort) is sufficient for primary functionality

## Next Session
- [ ] Decide: Drop bidirectional entirely OR defer to future version?
- [ ] Continue with message grouping (Phase 2) if proceeding
- [ ] Update CLAUDE.md with architecture decision

## Blockers / Open Questions
- **Technical blocker: Standard MIDI monitoring can't capture Rekordbox→controller**
  - Potential solutions:
    1. Custom CoreMIDI driver (high complexity)
    2. Virtual through-port requiring user setup (poor UX)
    3. Scope out bidirectional (simplest, meets 90% use case)
  - Recommendation: Option 3 for v1, revisit for v2 if users request it

## Notes / Discoveries
- IOPort.get_count() is reliable for input device enumeration
- "MIDI monitoring" ≠ "MIDI sniffing" in technical terms
- Rekordbox uses proprietary LED protocol (not standard MIDI feedback)
- macOS CoreMIDI doesn't expose "spy" capability to applications
```

---

### Example 3: Trivial Change (Skip Session Note)

**Context:** Fixed typo in CLAUDE.md

**User:** "Okay, that's done"

**Claude evaluates:**
- Trivial change (single typo fix)
- Fully complete (nothing to continue)
- No informal decisions or discoveries
- No multi-session work

**Verdict:** Skip session note

**Claude response:**
```
"Change committed. No session note needed for this simple fix."
```

---

## Updating / Amending Session Notes

Users can ask Claude to update session notes:

**User:** "Add to today's session note that we also discovered X"

**Claude:**
```bash
# Find today's session note
ls .claude-sessions/2025-12-21-*.md

# Read current content
# Use Edit tool to add discovery to "Notes / Discoveries" section
```

**Confirm:**
```
"Updated .claude-sessions/2025-12-21-context-recovery.md with discovery about X"
```

---

## Best Practices

### For Claude

**DO:**
- Suggest session notes proactively (don't wait to be asked)
- Be concise in notes (highlights, not novel)
- Focus on "Next Session" and "Decisions Made" sections
- Reference git commits when applicable
- Update CLAUDE.md if session revealed pending work

**DON'T:**
- Write session notes for every trivial interaction
- Ask about session notes for clearly complete work
- Write overly detailed notes (defeats "lightweight" purpose)
- Forget to create `.claude-sessions/` directory if missing

### Decision Template

When uncertain if session note is warranted, ask:

1. **Will user continue this work in a future session?** (Yes → write note)
2. **Did we make informal decisions not captured in git?** (Yes → write note)
3. **Is there context future Claude would benefit from knowing?** (Yes → write note)
4. **Is this just a trivial change?** (Yes → skip note)

---

## Integration with Context Recovery

Session notes feed into the context-recovery protocol:

**User (next session):** "Continue where we left off"

**Claude (with git-context-recovery skill):**
```bash
# Priority 1: Check git
git log --oneline -5
# Finds some commits but no phase documentation

# Priority 4: Check session notes
ls -lt .claude-sessions/ | head -1
# Shows: 2025-12-20-bidirectional-research.md

cat .claude-sessions/2025-12-20-bidirectional-research.md
# Reads "Next Session" section
```

**Claude responds:**
```
"Picking up from yesterday's session. We decided to defer bidirectional
monitoring (technical blocker). Next step is implementing message grouping
(Phase 2). Should I proceed?"
```

**Result:** Seamless continuation with full context

---

## Setup / Configuration

### Adding to Project

Session notes convention is project-level (not global). To enable:

1. **Create directory:**
```bash
mkdir -p .claude-sessions
```

2. **Add README (optional but helpful):**
```bash
cat > .claude-sessions/README.md <<'EOF'
# Claude Session Notes

Session notes for multi-day work continuity.

Convention: ~/.claude/conventions/session-notes.md
EOF
```

3. **Update project CLAUDE.md:**
```markdown
## Session Notes
- Uses: ~/.claude/conventions/session-notes.md
- Location: .claude-sessions/
- Claude proactively writes session notes for complex multi-day work
```

4. **Optional: Add to .gitignore**
```
.claude-sessions/
```
(Session notes are ephemeral; commit if you want history)

---

## Related Skills & Conventions

- **Convention:** `~/.claude/conventions/session-notes.md` - Session note structure and when to use
- **Convention:** `~/.claude/conventions/context-recovery.md` - How session notes fit context recovery
- **Skill:** `~/.claude/skills/git-context-recovery/SKILL.md` - Checks session notes as part of recovery

---

**This skill makes session notes happen automatically, ensuring multi-session work never loses context.**
