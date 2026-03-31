# Agent Diff Notes: ccconfig vs dotfiles-stow legacy

Comparing `/Users/ivan/proj/dotfiles-stow/.claude/agents/` (Dec 2025) against current ccconfig versions (Mar 2026).

Legacy copies saved at `configs/agents/*.legacy.md` for reference.

---

## kim.md

### In legacy, not in current

**Learning Loop section** — concrete `lessons-learned.md` entry template with date, task, solution, files changed, impact, pattern learned, reference URL, and `#tags`. Current version just says "log significant tasks" with no template. Worth adding back once it's clear kim has reliable access to `~/.claude/knowledge/` and can actually verify the file exists and follow the format.

**5-item pre-completion checklist** — legacy had:
1. Scope
2. Quality
3. Boundaries (did I avoid touching project content?)
4. Impact
5. Documentation (did I log lessons?)

Current has only 1, 2, 4. Items 3 and 5 were dropped. Item 5 depends on Learning Loop being wired up. Item 3 is a useful guardrail worth restoring independently.

**`TodoWrite` in tools** — legacy had it, current doesn't. Correct to omit — beads replaced it.

**Delegation Model section** — legacy had an explicit "You delegate, I execute" framing. Current absorbed this into prose. Minor difference.

### In current, not in legacy

- `Edit` tool added (correct)
- Tighter, less verbose execution protocol
- `context: fork` not present (kim doesn't need it)

---

## scout.md

### In legacy, not in current

**Technical Notes section** — three calibration anchors that make scout's assessments more consistent:

1. *Fit Scoring rubric*: High = 80-100 (solves 80%+ ready to use), Medium = 50-79 (core solved, notable gaps), Low = 0-49 (partial/tangential)
2. *Complexity Level time thresholds*: Simple = <15min, Moderate = 15-60min, Complex = >60min
3. *Quality Indicators*: what to check — stars/forks, recent commits, docs quality, issue resolution rate, integration patterns

This section is entirely additive and has no self-visibility dependency. Safe to add back whenever.

**Second example** (Iterative CLAUDE.md improvement) — demonstrates the "Alternative Approaches" section of the report format, which the current example doesn't show. The URLs in it are illustrative, not verified real links. Worth adding back with a caveat that URLs are examples.

**Explicit 6-step search strategy** — legacy spelled out: parse → query in parallel → filter → fetch top candidates → score → rank. Current lacks this. Useful operational guidance.

### In current, not in legacy

- `context: fork` (correct — scout does independent research)
- Much richer tool list: `mcp__brave-search`, `mcp__exa__*` tools — significant capability upgrade
- Description upgraded to 3 proactive trigger scenarios — much better routing signal
- `model: sonnet` explicit

---

## vibe-log-report-generator.md / vibe-log-session-analyzer.md

Only in dotfiles. Copied to ccconfig and symlinked to `~/.claude/agents/`. These are part of a vibe-log reporting ecosystem and depend on a `.vibe-log-temp/` directory populated by an external tool. Dormant until that's configured.
