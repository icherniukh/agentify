# Repository Inconsistencies Report & Fixes

Date: 2026-03-27  
Scope: Skills and agents in ccconfig repository

## Findings

### 1. Agent Frontmatter Inconsistencies

**Before:**
- `tools:` field format: mixed YAML array (`- item`) vs comma‑separated string
- `color:` field: present only in config‑cleaner (cyan) and kim (orange)
- `maxTurns:` field: present only in config‑cleaner (30)

**After fixes (applied):**
- Standardized `tools:` to comma‑separated string (no YAML dashes)
- Added missing `color:` to all agents:
  - config‑cleaner: cyan (unchanged)
  - kim: orange (unchanged)
  - scout: green
  - chris: red
  - major‑lazer: purple
- Added `maxTurns: 30` to all agents

**Updated agents:**
- `agents/scout.md`
- `agents/chris.md`
- `agents/major‑lazer.md`
- `agents/kim.md` (added maxTurns only)

### 2. Skill Frontmatter

**Status:** Consistent across all skills.
All skills have `---` frontmatter with `name:` and `description:` only.

### 3. Script File Permissions

**Checked:** Only one script found (`skills/context‑window‑inspector/test/run‑test.sh`). Already executable.

### 4. Directory Structure

**Variations:** Some skills include `references/`, `scripts/`, `templates/` directories. This is intentional and not an inconsistency — different skills have different needs.

### 5. File Naming

**Consistent:** All agent files are `.md` with kebab‑case names matching the `name:` field. All skill directories are kebab‑case.

## Recommendations

1. **Add a validation script** to check frontmatter consistency on CI.
2. **Document frontmatter standards** in `AGENTS.md` or a separate `CONTRIBUTING.md`.
3. **Consider adding `version:` field** to track changes (optional).

## Verification

Run `grep -n "tools:" agents/*.md` to confirm all use comma‑separated format.

```bash
$ grep -n "tools:" agents/*.md
agents/chris.md:5:tools: WebSearch, mcp__web_reader__webReader
agents/config-cleaner.md:4:tools: Read, Bash, Glob, Grep
agents/kim.md:4:tools: Read, Write, Edit, Bash, Glob, Grep, WebFetch, WebSearch
agents/major-lazer.md:5:tools: Read, Write, Edit, Bash, Glob, Grep
agents/scout.md:10:tools: WebSearch, WebFetch, Read, Grep, Glob
```

All consistent.

---

**This report documents the inconsistencies that were present and the fixes applied to standardize the repository.**