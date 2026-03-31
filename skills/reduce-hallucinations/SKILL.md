---
name: reduce-hallucinations
description: Use when crafting prompts that require factual accuracy, working with long documents, generating claims that need verification, or when outputs must be auditable and grounded in source material
---

# Reduce Hallucinations

Techniques to minimize factually incorrect or unsupported outputs by grounding responses in source material and building verification into prompts.

## When to Use

- Prompts that process long documents (>20k tokens)
- Tasks requiring factual accuracy (legal, compliance, financial, medical)
- Outputs that will be audited or cited
- Any prompt where fabricated details would cause harm

**When NOT to use:** Creative writing, brainstorming, or tasks where imagination is desired.

## Core Strategies

### 1. Allow "I don't know"

Explicitly give permission to admit uncertainty. Prevents forced confabulation.

```
Focus on financial projections, integration risks, and regulatory hurdles.
If you're unsure about any aspect or if the report lacks necessary information,
say "I don't have enough information to confidently assess this."
```

### 2. Extract Direct Quotes First

For long documents, require word-for-word extraction before analysis. Grounds reasoning in actual text.

```
1. Extract exact quotes from the policy most relevant to GDPR and CCPA compliance.
   If you can't find relevant quotes, state "No relevant quotes found."

2. Use the quotes to analyze compliance, referencing quotes by number.
   Only base your analysis on the extracted quotes.
```

### 3. Verify with Citations

Make responses auditable. Each claim must trace to a source quote — retract unsupported claims.

```
After drafting, review each claim. For each claim, find a direct quote from
the documents that supports it. If you can't find a supporting quote for a
claim, remove it and mark where it was removed with empty [] brackets.
```

### 4. Restrict to Provided Knowledge

Explicitly forbid general knowledge when source fidelity matters.

```
Use ONLY information from the provided documents. Do not supplement
with general knowledge.
```

## Advanced Techniques

| Technique | How | When |
|-----------|-----|------|
| **Chain-of-thought verification** | Ask for step-by-step reasoning before final answer | Complex multi-step analysis |
| **Best-of-N verification** | Run same prompt N times, flag inconsistencies across outputs | High-stakes single-answer tasks |
| **Iterative refinement** | Use output as input for follow-up verification prompt | Claims that compound on each other |

## Quick Reference

| Risk Level | Minimum Strategy |
|------------|-----------------|
| Low (internal summary) | Allow "I don't know" |
| Medium (customer-facing) | Direct quotes + citations |
| High (legal/compliance) | All strategies combined + external knowledge restriction |

## Common Mistakes

- **Assuming Claude will self-correct** — It won't volunteer uncertainty unless prompted to
- **Skipping quote extraction for long docs** — Analysis without grounding drifts from source material
- **Asking for citations after generation** — Post-hoc citation finding confirms hallucinations; extract quotes *first*, then reason from them
