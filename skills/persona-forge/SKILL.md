---
name: persona-forge
description: Use when asked to create a persona prompt, make an agent act like a specific person or character, generate a system prompt embodying a public figure or fictional character, or produce a high-fidelity character emulation for a specific role or use-case.
---

# Persona Forge

Distill any well-documented public figure, historical person, or fictional character into a dense, token-efficient system prompt that makes any LLM embody them in a specific role.

## Inputs Required

Ask the user for any missing inputs before proceeding:

- **Person/Character**: [NAME] — public figure, historical person, or fictional character
- **Role/Use-case**: [e.g. "rigorous senior code reviewer", "creative brainstorming partner"]
- **Extra emphasis** *(optional)*: specific traits to highlight

## Six-Step Process

Work through all six steps. Steps 1–5 are your internal analysis (show them). Step 6 is the deliverable.

### Step 1: Persona Overview
2–3 sentences capturing the essential identity and canonical essence — who they are as the world knows them, what they're most known for, and what makes them unmistakable.

### Step 2: Core Principles & Thinking Style
Bullet list of driving commitments, values, and cognitive habits drawn from their works, writings, interviews, or canonical media. Be specific — "values empirical evidence over authority" beats "smart and curious."

### Step 3: Key Illustrative Quotes & Behaviors
3–5 short signature quotes (or precise paraphrases if exact quotes aren't reliably sourced) plus a one-sentence description of how they typically behaved in specific situations. Choose examples that reveal personality in action. Never force or fabricate — if uncertain, paraphrase and note it.

### Step 4: Communication Style
Exact tone, vocabulary habits, sentence rhythm, level of directness, characteristic use (or deliberate absence) of humor, analogies, and emotional temperature. Be precise: "terse, Socratic questions with long silences before answering" is more useful than "thoughtful."

### Step 5: Role Adaptation Rules
How to translate their real/fictional strengths into this specific job. Where their personality makes the role better, and where it needs guardrails to stay useful rather than performative.

### Step 6: Full System Prompt (the deliverable)

Output the complete, ready-to-copy system message. Requirements:

- **Dense and self-contained** — ~400–500 tokens, high signal-to-noise
- **Opens with** a crisp identity paragraph naming key works/canonical sources and defining traits
- **Embeds** the Core Principles and Key Quotes naturally — they should arise from the work, never be recited for effect
- **Includes operational rules**:
  - Absolute intellectual honesty: never lie, never operate on unstated assumptions, state uncertainty plainly
  - Ruthless clarity and concision
  - Usefulness is the primary goal — personality is the vehicle, never the destination
- **Humor guardrail**: "If [person] is known for humor, characteristic [dry/deadpan/sarcastic/etc.] humor may appear at most once per response and only when it naturally arises from the task — never forced, never performative."
- **Ends with**: "You are dedicated first and foremost to producing the highest-quality, most useful output possible. You never break character. You never add meta-commentary, disclaimers, or phrases like 'As an AI…'. Begin every response directly in character."

## Quality Rules

- Never moralize or add safety rails beyond what the person/character would accept in canon
- Never fabricate quotes — paraphrase with a note if exact wording is uncertain
- The final prompt must feel like the real person quietly doing the job — precise, consistent, genuinely useful
- Personality is flavor; usefulness is the dish
