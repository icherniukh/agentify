# Project State: Claude Code Optimizer Design

**Last Updated:** 2025-10-30
**Project:** up_claude (Claude Code workflow optimization agent design)
**Status:** Active

---

## Current Work Session

### Active Tasks
- Evaluating task workflow convention (Original vs Optimized vs Hybrid)
- Standardizing workflow for managing open questions and todos

### Recent Completions
- ✅ Optimized task workflow system (reduced from 1,134 to 641 lines)
- ✅ Agent comparison of workflow documents completed by code-reviewer

---

## Pending Decisions

### 1. Task Workflow Convention Version
**Question:** Which version to use?
- **Original:** `/Users/ivan/proj/midi/TASK_ORGANIZATION_CONVENTION.md` (1,134 lines)
- **Optimized:** `/Users/ivan/proj/up_claude/TASK_WORKFLOW_CONVENTION_OPTIMIZED.md` (641 lines)
- **Recommendation:** Hybrid approach (Kim's code review suggests combining both)
- **Decision by:** User (deferred)

### 2. Codename Necessity
**Question:** Are codenames (monkey, eagle, etc.) actually needed?
- **Agent recommendation:** REMOVE codenames entirely
- **Rationale:** Date + type is sufficient; codenames add cognitive overhead
- **Alternative:** `/tasks/102925_architecture_review/` instead of `/tasks/102925_monkey_architecture/`
- **Decision by:** User (pending review)

### 3. Workflow Standardization
**Question:** How to manage open questions, todos, pending decisions?
- **Current issue:** Todos stored per-session in `~/.claude/todos/<uuid>.json` - not discoverable
- **Need:** Standardized workflow for PROJECT_STATE.md, todo lists, open questions
- **Decision by:** User (pending)

---

## Open Questions

1. Who/what is "Kim"? (User mentioned Kim should do comparison, but no Kim agent exists)
2. Should PROJECT_STATE.md be in project root or `.claude/`?
3. Should open questions live in PROJECT_STATE.md or separate file?

---

## Todo List

### Completed
- [x] Optimize task workflow system and remove redundancies

### Pending
- [ ] Review agent recommendation to remove codenames from task workflow
- [ ] Decide which task workflow version to use (Original vs Optimized vs Hybrid)
- [ ] Move chosen task workflow convention to global location (~/.claude/conventions/)
- [ ] Standardize workflow for managing open questions, task lists, and pending decisions

---

## Key Documents

### Task Workflow Convention
- Original: `/Users/ivan/proj/midi/TASK_ORGANIZATION_CONVENTION.md`
- Optimized: `/Users/ivan/proj/up_claude/TASK_WORKFLOW_CONVENTION_OPTIMIZED.md`
- Comparison: Created by code-reviewer agent

### Claude Code Optimizer Design
- Main design: `/Users/ivan/proj/up_claude/CLAUDE_CODE_OPTIMIZER_DESIGN.md`
- Implementation guide: `/Users/ivan/proj/up_claude/AGENT_IMPLEMENTATION_GUIDE.md`
- Quick reference: `/Users/ivan/proj/up_claude/QUICK_REFERENCE.md`
- Start here: `/Users/ivan/proj/up_claude/START_HERE.md`

---

## Session Notes

### 2025-10-30 Session
- Discovered task workflow already optimized yesterday (no duplicate work needed)
- Agent (docs-architect) recommended removing codenames entirely
- Code-reviewer agent (mistakenly called "Kim") compared both workflow versions
- Identified that todo lists are stored per-session and not discoverable
- Created this PROJECT_STATE.md file to solve discoverability issue

---

## Next Steps

1. User to review codename recommendation
2. User to decide on workflow version (Original/Optimized/Hybrid)
3. Design standardized workflow for state management
4. Deploy chosen workflow convention to `~/.claude/conventions/`
