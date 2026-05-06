# Promptonality Skill Variants Spec

Status: superseded
Date: 2026-04-02
Superseded by: `docs/personality-strategy.md`

## Supersession Note

This document captures an older compiled-variant direction. It is preserved as
design history, not as the current project spec.

The active model is asset-first:

- personas are portable pack assets
- users can add and update their own packs
- entrypoint skills discover, validate, list, and compose packs
- dedicated per-persona wrapper skills are not the default product shape

See `docs/personality-strategy.md` for the current fundamental promises.

## Purpose

Define the simplest viable model for how `promptonality` should create and manage personality-flavored skills.

This spec incorporates the decision to simplify the user-facing model to:

- `new skill`
- `variant`

It also resolves the question of whether the framework should internally distinguish between:

- "use this skill with personality"
- "make a derived editable copy"

Current recommendation: **no user-facing distinction, and no primary internal distinction unless runtime constraints force it**.

## Problem

`promptonality` needs to let users:

- create brand-new skills with a personality lens
- apply a personality lens to an existing skill
- preserve the original skill unchanged
- later customize the flavored result without losing provenance

The framework should do this without:

- mutating third-party or shared installed skills in place
- forcing users to understand packaging internals
- paying unnecessary prompt overhead at runtime

## Decision Summary

### User Model

The product exposes only two concepts:

- `new skill`: a skill authored from scratch
- `variant`: a personality-flavored derivative of an existing skill

### Internal Model

The framework should treat `variant` as the primary internal concept too.

A variant may be stored as:

- a source definition
- a compiled runnable skill

But those are implementation details, not separate product concepts.

Do not expose `adapter`, `fork`, or `patch` as first-class UX concepts.

## Why `variant`

`variant` is the cleanest term because it means:

- derived from something real
- original remains intact
- differences are intentional
- divergence is allowed but not implied

Avoid:

- `fork`: sounds like permanent upstream divergence
- `adapter`: describes implementation, not user intent
- `patched`: sounds low-level and temporary

## Goals

- Keep the model obvious to a non-framework author.
- Preserve base skill ownership boundaries.
- Make flavored skills editable without editing the original.
- Keep runtime prompt assembly token-efficient.
- Support provenance, regeneration, and later detachment.

## Non-Goals

- Live mutation of arbitrary installed skills in place
- Automatic semantic merging of upstream updates
- Hidden runtime imports that depend on undocumented platform behavior
- Universal personality retrofitting for every skill format

## Practical Finding From Current Repo

Measured on the current `promptonality` example assets:

- neutral orchestrator core: 263 words
- Sam wrapper skill: 203 words
- Sam pack YAML: 542 words
- naive `core + wrapper + pack`: 1008 words
- compiled `core + pack` packet used by current tests: 799 words

Implication:

- wrapper-only is not sufficient as a real runtime artifact because it does not carry the behavior on its own
- naive three-layer injection is wasteful
- a compiled flat runtime packet is materially leaner than injecting all three pieces

This is not a precise tokenizer benchmark, but it is enough to drive architecture:

- do not make runtime depend on stacking multiple full prompt layers when a compiled variant can flatten them

## Core Model

### 1. New Skill

A `new skill` is fully owned by `promptonality` from the start.

It has no required base skill provenance.

It may optionally use a personality pack during creation, but after generation it stands alone as its own skill.

### 2. Variant

A `variant` is a derived skill created from:

- one base skill
- zero or one personality pack
- optional local behavior edits

The original skill is never modified during variant creation.

The variant becomes the editable local artifact.

## Variant Lifecycle

### Create

Inputs:

- base skill
- selected personality pack
- optional rename
- optional local behavior changes

Output:

- a new local variant skill with provenance metadata

### Edit

Allowed edits:

- flavor adjustments
- structure adjustments
- response-format preferences
- task-specific strengthening

Disallowed default behavior:

- editing the original base skill in place

### Refresh

If the base skill changes upstream, the system may offer:

- rebuild variant from latest base
- keep current variant as-is
- inspect diff before rebuild

This should be explicit and user-controlled.

### Detach

A variant can later be converted into a standalone `new skill`.

Use this when the variant has evolved enough that provenance to the base no longer matters operationally.

## Runtime Strategy

### Recommendation

Use a **compiled runtime skill** as the primary execution artifact.

That means:

- authoring may remain compositional
- runtime delivery should be flattened into one runnable instruction packet

This avoids dependence on hidden or inconsistent runtime composition behavior.

### Why

Because the current plugin model is explicitly not a hidden import system.

If a runtime only injects one skill file, then a wrapper that merely points to other files is not enough.

A compiled runtime artifact gives:

- predictable behavior
- easier testing
- lower prompt overhead than naive layer stacking
- better portability across runtimes

## Authoring Strategy

Internally, a variant should have two layers:

### Source Layer

The editable definition of the variant:

- base skill reference
- personality pack reference
- local variant instructions
- provenance metadata

### Runtime Layer

The generated runnable skill packet:

- flattened base behavior
- flattened personality overlay
- flattened local variant edits

The source layer is the system of record.

The runtime layer is generated.

## File Model

Recommended shape for a variant:

```text
plugins/promptonality/generated-skills/<variant-id>/
  SKILL.md
  variant.json
```

Where:

- `SKILL.md` is the compiled runnable skill
- `variant.json` stores provenance and generation inputs

Recommended `variant.json` fields:

```json
{
  "id": "sam-harris-orchestrator-variant",
  "display_name": "Sam Harris Orchestrator Variant",
  "kind": "variant",
  "base_skill": "plugins/promptonality/src/skills/orchestrator-core/SKILL.md",
  "personality_pack": "plugins/promptonality/src/assets/personalities/sam-harris.yaml",
  "local_edits": [],
  "created_by": "promptonality",
  "created_at": "2026-04-02",
  "source_mode": "composed",
  "runtime_mode": "compiled"
}
```

This preserves the simple concept while retaining enough internal state to regenerate.

## Editing Rules

### What Users Edit

Users edit the variant they own.

They should be able to:

- regenerate from source inputs
- edit the local variant instructions
- swap personality packs
- detach into a standalone skill

### What Users Do Not Edit By Default

Users do not edit:

- the installed original skill
- third-party skill directories
- shared plugin-owned canonical assets unless they explicitly own them

## Product Workflow

### Workflow A: New Skill

1. Choose `new skill`.
2. Optionally choose a personality pack.
3. Generate the skill.
4. Preview the runnable skill text.
5. Save it as an owned local skill.

### Workflow B: Variant

1. Choose `variant`.
2. Choose base skill.
3. Choose personality pack.
4. Preview the behavior delta.
5. Save as a local variant.
6. Optionally customize the variant.

### Workflow C: Evolve Variant

1. Open existing variant.
2. Edit flavor or behavior.
3. Rebuild compiled runtime artifact.
4. Run checks.

## Preview Requirements

Before saving a variant, show:

- base skill name
- selected personality pack
- variant name
- estimated prompt size delta
- compiled output preview or diff summary

This is especially important because personality changes are easy to overshoot.

## Testing Requirements

Every saved variant should support:

- package validation
- compile validation
- behavior smoke test

Optional but strongly recommended:

- small live-eval cases comparing base vs variant

Current tests in `plugins/promptonality/test/` already point in the right direction:

- package shape tests
- packet compilation tests
- behavior difference tests
- live model comparison tests

## Recommendation On Internal Separation

Do not build separate internal systems for:

- compositional "use this skill with personality"
- derived editable "patched/flavored copy"

unless a later benchmark proves the distinction buys meaningful value.

For now, one model is enough:

- everything derived from an existing skill is a `variant`
- variants are authored compositionally
- variants run as compiled skills

This is simpler than keeping multiple ontologies alive.

## Future Benchmarking

If you want to revisit the architecture later, benchmark three modes:

1. wrapper-only reference mode
2. naive layered injection mode
3. compiled flat variant mode

Measure:

- prompt size
- model compliance with base behavior
- strength of personality signal
- maintenance cost when base skills change

Expected winner:

- compiled flat variant mode

It has the best balance of portability, predictable behavior, and prompt efficiency.

## Final Recommendation

`promptonality` should standardize on this model:

- user chooses `new skill` or `variant`
- original skills remain untouched
- `variant` is the only derivative concept
- variants are editable owned artifacts
- authoring can be compositional
- runtime should be compiled and flat

That gives the framework a simple story, a clean UX, and a realistic implementation path.
