---
name: diagnosing-bugs
description: Diagnoses errors, regressions, flaky failures, and production-only or infrastructure failures by proving a root cause. Use when the user asks to investigate why a failure happens, reproduce a bug, or identify the cause of an incident, rather than simply implement a requested change.
metadata:
  "opencode/autoinvoke": false
  "opencode/slash": true
---

# Diagnosing Bugs

Investigate the failure as an evidence problem. The goal is a demonstrated cause and a regression guard, not a plausible patch.

## Boundaries

- Trigger for root-cause investigation of an error, regression, flaky test, incident, or environment/infrastructure-only failure.
- Do not trigger for ordinary feature implementation, broad refactoring, or a request to review a change. Those workflows have different goals.
- Do not commit automatically. Do not mutate production, alter tickets, or use unsafe commands. Ask before any action that could change a live system.
- Follow the repository's test policy. In particular, do not create mocked dependency harnesses. Use a real unit test for pure logic or a real end-to-end path for boundaries.

## Workflow

### 1. Define the symptom and the proof loop

Write down the exact observed symptom, expected behavior, affected scope, first known occurrence, and relevant environment. Then build the tightest feedback loop that can prove the bug:

1. Run the smallest existing test, command, request, or reproduction that shows the failure.
2. Capture the exact input, output, error, logs, timing, versions, and exit status.
3. Minimize the reproduction while preserving the symptom. If it cannot be minimized, state why.
4. Prefer a deterministic local loop. Add temporary, narrowly scoped instrumentation only when it shortens the loop, and plan its removal immediately.

Do not start by changing code. A fast, faithful loop prevents fixing a nearby symptom.

### 2. Build and test hypotheses

Maintain an evidence log as you work. Separate:

- **Facts:** directly observed outputs, code paths, configuration, history, and test results.
- **Assumptions:** claims not yet verified.
- **Hypotheses:** possible causes, ranked by impact, explanatory power, and how cheaply they can be falsified.

For each hypothesis, record one prediction and test only that prediction before moving on. Prefer tests that distinguish hypotheses. Record disproven hypotheses too, so the investigation does not cycle.

Trace the complete path, not just the failing line: inputs and validation, state transitions, error handling, concurrency and timing, retries and idempotency, persistence and wire formats, configuration, dependencies, deployment, and the first point where observed behavior diverges from the contract.

### 3. Use production evidence safely

When local reproduction is impossible, use read-only evidence: application logs, structured events, traces, metrics, deployment history, configuration snapshots, database metadata, queue state, and infrastructure inspection. Bound queries by time, service, request, and cost. Redact secrets and personal data.

Invoke an existing relevant domain skill when one is available, such as a database, Kubernetes, cloud-cost, or log-analysis skill. It is optional; this skill remains usable without it. Never turn an investigation into a production mutation or a speculative rollout.

### 4. Fix and prove

Once evidence identifies the root cause:

1. Make the smallest maintainable root-cause fix, preserving valid behavior and error semantics.
2. Add a real unit or end-to-end regression test that fails before the fix and passes after it. Do not weaken assertions or encode an implementation detail unnecessarily.
3. Re-run the original reproduction and relevant neighboring tests.
4. Check logs, metrics, timing, and failure handling for regressions.
5. Remove temporary instrumentation, debug flags, data, and generated artifacts.

If evidence is insufficient, stop at the strongest supported conclusion and surface the uncertainty, missing evidence, and safest next experiment. Do not present a guess as a root cause.

## Evidence log

Keep a compact working record:

```text
Symptom: ...
Environment/scope: ...
Facts:
- ...
Hypotheses:
- H1 [rank]: prediction ... / result ...
Root cause: ... (or unresolved)
Commands/tests/evidence: ...
```

## Final report

Return:

1. **Symptom and scope**
2. **Root cause**, with the evidence that proves it
3. **Fix and regression test**, including paths or commands
4. **Verification**, including the original reproduction
5. **Residual uncertainty or follow-up**, if any
