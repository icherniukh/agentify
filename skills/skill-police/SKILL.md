---
name: skill-police
description: Use when auditing skills for spec compliance, reviewing skill descriptions, checking frontmatter structure, or fixing common skill authoring violations. Provides the exact rules and a checklist to verify any skill file.
---

# Skill Police

Reference for auditing skill files against the official spec. Use this before deploying a skill or when asked to review one.

## Frontmatter Rules

```yaml
---
name: kebab-case-name-only          # letters, numbers, hyphens ONLY — no parens, no special chars
description: Use when [triggering conditions and symptoms only]
---
```

**Standard fields:** `name` and `description`. Extra fields are allowed when they serve a clear, specific purpose (e.g. `spec-commit` to track which version of a source spec the skill was written against). Reject arbitrary or redundant extra fields.

**Max 1024 characters total** across both fields.

## Description Rules (Most Violated)

```yaml
# ❌ Summarizes workflow — Claude may follow this INSTEAD of reading the skill
description: Automatically checks git history to recover work context when user references previous work

# ❌ Describes what the skill is
description: Ghostty terminal configuration reference — config syntax, keybindings...

# ❌ Awkward third-person intro
description: This skill should be used when reviewing PCQ answers...

# ❌ Doesn't start with "Use when"
description: Periodic self-audit of Claude Code configuration quality

# ✅ Triggering conditions only, starts with "Use when"
description: Use when configuring Ghostty, creating keybindings, setting up profiles, or troubleshooting terminal config.

# ✅ Symptoms + situations, no workflow
description: Use when designing or reviewing Python classes, deciding where logic belongs, or recognizing antipatterns like helper classes, utility bags, and god objects.
```

**Key rule:** Description = WHEN to use, not WHAT it does or HOW it works. Summarizing workflow in the description creates a shortcut Claude follows instead of reading the skill body.

## Structure Rules

```
skills/
  skill-name/       # directory, not flat .md file
    SKILL.md        # required
    references/     # only if heavy reference (100+ lines)
    supporting.*    # only for reusable tools/scripts
```

**Flat `.md` files** (e.g. `skills/beads.md`) violate the directory structure requirement.

## Length Targets

| Skill type | Target |
|-----------|--------|
| Frequently-loaded / getting-started | < 200 words |
| Standard skills | < 500 words |
| Reference skills with heavy docs | OK to be long — move to `references/` |

Skills like `session-notes-writer` (473 lines) and `self-audit` (569 lines) are bloated. Narrative examples, "before this skill / with this skill" sections, and step-by-step pseudo-code that belongs in the body all inflate token cost with zero reuse value.

## Audit Checklist

Run against any skill file:

**Frontmatter**
- [ ] Only `name` and `description` fields — no extras
- [ ] `name` uses only letters, numbers, hyphens
- [ ] Total frontmatter ≤ 1024 characters

**Description**
- [ ] Starts with "Use when..."
- [ ] Describes triggering conditions / symptoms only
- [ ] Does NOT summarize the skill's workflow or process
- [ ] Written in third person
- [ ] Technology-agnostic triggers unless skill is tech-specific

**Structure**
- [ ] Located at `skills/<name>/SKILL.md`, not `skills/<name>.md`
- [ ] Supporting files only if reusable tools or heavy reference (100+ lines)

**Content**
- [ ] Within length targets (see table above)
- [ ] No narrative "before/after this skill" storytelling
- [ ] Cross-skill references use skill name only (no `@` force-loads)
- [ ] No emoji unless explicitly requested

## Common Violations Table

| Violation | Example | Fix |
|-----------|---------|-----|
| Describes skill instead of trigger | `"Ghostty terminal configuration reference —"` | Start: `"Use when configuring Ghostty..."` |
| Workflow summary in description | `"Automatically checks git history to recover context"` | `"Use when user references previous work phases or asks to continue prior work"` |
| Arbitrary frontmatter fields | `version: 2`, `type: reference` | Delete unless it has a clear tracking purpose |
| Flat file structure | `skills/beads.md` | Move to `skills/beads/SKILL.md` |
| Narrative storytelling | "Before this skill: Claude forgets. With this skill: Claude remembers." | Delete — show behavior in examples only |
| Oversized skill | 569-line audit skill | Move examples to `references/`, trim to core patterns |

## Quick Fix Patterns

**Fixing a non-"Use when" description:**
1. Identify the actual triggers (when should Claude load this skill?)
2. Start with "Use when [those triggers]"
3. Remove any process/workflow language

**Fixing oversized skills:**
1. Identify examples that illustrate the same pattern — keep one, delete rest
2. Move API docs / heavy reference material to `references/`
3. Replace step-by-step procedures with concise guidance
4. Target: can you cut 30% without losing the rule?
