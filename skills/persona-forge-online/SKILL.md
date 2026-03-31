---
name: persona-forge-online
description: Use when asked to create a high-fidelity persona prompt with web research, when accuracy matters more than speed, when the person/character is less famous or obscure, or when the user wants a comprehensive and well-sourced persona system prompt. Research-backed version of persona-forge.
---

# Persona Forge (Online / Research-Backed)

Like persona-forge, but grounds every claim in researched source material before generating the system prompt. Use when fidelity and accuracy matter more than speed, or when the subject is obscure enough that training data alone is unreliable.

## Inputs Required

Ask the user for any missing inputs before proceeding:

- **Person/Character**: [NAME] — public figure, historical person, or fictional character
- **Role/Use-case**: [e.g. "rigorous senior code reviewer", "creative brainstorming partner"]
- **Extra emphasis** *(optional)*: specific traits to highlight

---

## Phase 1: Research

Before any analysis, gather source material. Run searches in parallel where possible.

### 1A. Breadth Search
Search for an overview of the person/character's public identity, reputation, and what they're most known for:
- `"[NAME] personality traits` / `[NAME] thinking style` / `[NAME] philosophy`
- For fictional characters: `[NAME] [show/book] character analysis`

### 1B. Primary Source Hunt
Search for direct quotes, interviews, writings, and documented behaviors:
- `[NAME] quotes` / `[NAME] interview` / `[NAME] in their own words`
- `[NAME] letters` / `[NAME] speeches` / `[NAME] writings` (where applicable)
- For fictional characters: look for writer/creator commentary and canonical scenes

### 1C. Behavioral Documentation
Search for how they actually behaved in specific high-stakes or characteristic situations:
- `[NAME] how they worked` / `[NAME] management style` / `[NAME] decision making`
- `[NAME] famous anecdotes` / `[NAME] collaborators describe`

### 1D. Fetch & Extract
For the most promising 2–3 URLs from the above searches, fetch the pages and extract:
- Verbatim quotes (copy exactly, note source URL)
- Described behaviors and reactions
- Recurring themes across multiple sources

### Research Quality Check
Before proceeding, verify:
- [ ] At least 3 distinct primary or secondary sources consulted
- [ ] All quotes are verbatim or explicitly marked as paraphrases
- [ ] Sources span different contexts (work, personal, under pressure) where available
- [ ] For fictional characters: canonical sources prioritized over fan analysis

---

## Phase 2: Analysis (show your work)

With source material in hand, work through each step and cite sources inline.

### Step 1: Persona Overview
2–3 sentences capturing essential identity and canonical essence. Cite the sources that shaped this summary.

### Step 2: Core Principles & Thinking Style
Bullet list of driving commitments, values, and cognitive habits — each traceable to at least one researched source. Mark inferences explicitly: *(inferred from [source])*.

### Step 3: Key Illustrative Quotes & Behaviors
3–5 quotes pulled directly from research. Format:

> "Exact quote here." — Source, context

If exact wording is uncertain, mark it: *(paraphrase — [source] describes this as...)*

Plus one-sentence description of a specific documented behavior for each.

### Step 4: Communication Style
Precise characterization of tone, vocabulary, sentence rhythm, directness, humor type (or its absence), and emotional temperature — grounded in the quotes and sources collected, not impressions.

### Step 5: Role Adaptation Rules
How researched traits translate into this specific role. Where their actual documented strengths make the role better, and where guardrails are needed.

---

## Phase 3: Output

### Step 6: Full System Prompt (the deliverable)

Output the complete, ready-to-copy system message. Requirements:

- **Dense and self-contained** — ~400–500 tokens, high signal-to-noise
- **Opens with** a crisp identity paragraph naming key works/canonical sources and defining traits
- **Embeds** Core Principles and Key Quotes naturally — they arise from the work, never recited for effect
- **Includes operational rules**:
  - Absolute intellectual honesty: never lie, never operate on unstated assumptions, state uncertainty plainly
  - Ruthless clarity and concision
  - Usefulness is the primary goal — personality is the vehicle, never the destination
- **Humor guardrail**: "If [person] is known for humor, characteristic [dry/deadpan/sarcastic/etc.] humor may appear at most once per response and only when it naturally arises from the task — never forced, never performative."
- **Ends with**: "You are dedicated first and foremost to producing the highest-quality, most useful output possible. You never break character. You never add meta-commentary, disclaimers, or phrases like 'As an AI…'. Begin every response directly in character."

---

## Quality Rules

- Never use a quote you couldn't find in research — paraphrase with source attribution or omit
- If sources conflict on a trait, note the conflict and default to the majority or most primary source
- Personality is flavor; usefulness is the dish
- After delivering the prompt, list the sources consulted so the user can verify
