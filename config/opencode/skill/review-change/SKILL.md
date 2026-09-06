---
name: review-change
description: Reviews a branch, pull request, or diff for correctness and blast radius, ranking concrete defects and operational risks. Use when the user asks for code review, change safety, what could break, or whether a proposed change is ready, not when they ask to implement or repair it.
---

# Review Change

Review the change as a read-only risk assessment. Find defects that matter, explain their evidence, and make the review actionable without turning it into a style debate.

## Boundaries

- Review the requested branch, pull request, diff, or change set. Do not fix files, alter branches, commit, push, transition tickets, or modify remote state.
- Do not invent acceptance criteria, repository conventions, or runtime behavior. Inspect them.
- Do not report uncodified style preferences as defects. Avoid speculative findings unless the uncertainty itself is a material risk.

## Establish the fixed point

First identify the repository, current branch, target/base branch or commit, and any user-specified scope. Resolve ambiguity before judging behavior. For a branch or PR, establish the intended base without mutating branches, then inspect the full three-dot range (`base...head`), including changed files, renames, deletions, generated files, and tests. A working-tree diff is not a substitute for the committed change scope.

Read repository instructions, CI workflows, build/test configuration, and available specification or ticket context. Separate three questions throughout the review:

1. **Standards compliance:** does it follow repository and platform rules?
2. **Specification correctness:** does it satisfy the stated contract and user-visible behavior?
3. **Operational risk:** what can fail, degrade, or become difficult to recover after release?

## Trace blast radius

Start with the changed behavior, then follow its public contracts and consumers beyond direct text matches. Inspect the relevant subset of:

- exported APIs, callers, schemas, serialization, wire formats, and compatibility promises
- database queries, migrations, indexes, data shape, backfills, and rollback behavior
- queues, events, downstream services, asynchronous timing, races, retries, deduplication, and idempotency
- dependency versions, transitive behavior, feature flags, deployment/configuration, and infrastructure
- authorization, authentication, secrets, input validation, privacy, and trust boundaries
- performance, resource limits, caching, rate limits, observability, alerting, and debuggability
- failure modes, partial rollout behavior, backward compatibility, and a practical rollback path

Use history only when it explains an invariant or compatibility decision. Read enough surrounding implementation and tests to understand the contract, not merely the changed lines.

## Verify the safety case

Identify the one or two safety facts the change depends on, such as “all callers tolerate this new nullability” or “the migration is reversible before deployment.” Verify each with real code, repository tests, a bounded build/type check, a focused execution, or read-only inspection. Prefer an existing real unit or end-to-end test. Do not add mocks or change the code to make the review easier.

If a command would mutate state, ask before running it and keep the review read-only by default. Record unavailable tools, unrun checks, and environment differences as verification gaps.

## Findings

Report only evidence-backed issues. Rank them by impact:

- **Critical:** likely data loss, security exposure, outage, or unrecoverable deployment failure
- **High:** likely broken contract, serious correctness defect, or broad production impact
- **Medium:** real defect with bounded impact, degraded reliability, or unsafe edge case
- **Low:** concrete maintainability or operational issue worth addressing, not a preference

Every finding includes:

```text
[Severity] Short title
Location: path:line or precise symbol
Impact: what breaks, for whom, and under what condition
Evidence: code, test, execution, or specification that supports it
Remedy: the smallest clear correction or decision needed
```

Do not bury findings in a file-by-file summary. If no concrete defect is found, say so plainly, then list residual risks and verification gaps, especially anything that could not be exercised.

## Final report

Use this order:

1. **Scope and fixed point**
2. **Findings**, highest severity first
3. **Safety facts verified**
4. **Residual risks and verification gaps**
5. **Overall assessment**: ready, ready with follow-up, or not ready

Optionally invoke acceptance-criteria, change-scope, or domain-specific skills when useful, but remain functional if they are unavailable.
