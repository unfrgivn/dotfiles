---
name: grilling
description: Grills a design, plan, or requirements set by exposing missing decisions, dependencies, and risky assumptions. Use only when the user clearly asks for a challenge, interrogation, decision review, or requirements grilling, not for ordinary questions or implementation.
metadata:
  "opencode/autoinvoke": false
  "opencode/slash": true
---

# Grilling

Challenge the proposal constructively until the remaining ambiguity is cheap to carry or requires evidence and prototyping. The output is a decision record, not an endless questionnaire.

## Trigger discipline

Use this skill only when the user explicitly requests a grilling, hard questions, design challenge, plan critique focused on missing decisions, or requirements interrogation. Do not use it for a normal implementation request, routine explanation, or ordinary code review.

Stay within the requested scope. Do not create or edit files, mutate tickets, commit, push, or change external systems unless the user separately requests that action.

## Prepare from evidence

Before asking questions, inspect the available code, docs, tests, configuration, history, and tool output. Look for facts the repository can answer itself. Distinguish:

- **Decisions:** chosen options with an owner and rationale
- **Dependencies:** decisions or systems that must exist first
- **Assumptions:** claims awaiting evidence
- **Risks:** plausible consequences with a condition and impact
- **Questions:** unresolved choices that can change the plan

Build a decision tree from the goal, constraints, system boundaries, and possible options. Mark the **decision frontier**, the first unresolved choice that blocks meaningful downstream work. Ask at that frontier, not about every branch at once.

## Ask in manageable rounds

In each round:

1. Ask only currently unblocked questions. Group closely coupled questions, but keep the round small enough to answer without a workshop.
2. Put a recommended answer first for every question.
3. Give one brief rationale or tradeoff, then concise alternatives.
4. Prefer choices that preserve reversibility, satisfy explicit constraints, and reduce the most consequential uncertainty.
5. Investigate facts with repository tools instead of asking the user to fetch them.

Use this format:

```text
Q1. Which boundary should own this behavior?
Recommended: the API layer.
Why: it preserves one validation contract for all callers.
Alternatives: client-side validation (faster feedback, not authoritative); shared library (more reuse, larger rollout).
```

Do not ask questions whose answer is already in the code or documents. Do not disguise a preference as a requirement. If an answer depends on a missing fact, name the fact and suggest the smallest read-only inspection or prototype that would resolve it.

## Maintain the decision state

After each round, update a compact state table:

| Item | Status | Consequence |
| --- | --- | --- |
| Decision or assumption | decided / open / disproven | what it enables or blocks |

Recompute the decision frontier and expose newly unlocked questions only in the next round. Keep dependencies visible, including who or what owns them. Call out contradictions between requirements instead of silently choosing one.

Stop when ambiguity is low-risk, the user asks to stop, or the remaining choices require evidence, implementation, or prototyping. Do not keep grilling for theoretical completeness.

## Final output

Provide:

1. **Decision summary:** chosen answers and their rationale
2. **Open assumptions:** only those that still matter
3. **Dependencies and risks:** owners, conditions, and impact
4. **Next actions:** the smallest evidence-gathering, prototype, or implementation steps
5. **Decision frontier:** the next question, if one remains
