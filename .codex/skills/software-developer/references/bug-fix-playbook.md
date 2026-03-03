# Bug Fix Playbook

## 1. Problem Framing

- Capture expected behavior vs actual behavior.
- Capture environment, trigger conditions, and reproducibility.
- Gather artifacts: logs, stack traces, recent changes, failing tests.

## 2. Root Cause Analysis

- Reproduce with the smallest reliable test case.
- Isolate fault domain (input validation, state transition, concurrency, persistence, integration, etc.).
- Determine if issue is deterministic, intermittent, or load-dependent.

## 3. Fix Path Decision

Use targeted fix immediately when all are true:
- Root cause is clear.
- Blast radius is small and localized.
- Validation can be completed quickly with strong confidence.

Use planned fix with user confirmation when any are true:
- Root cause is uncertain or multi-factor.
- Fix touches multiple subsystems or risky migrations.
- Behavior tradeoffs require product or operational decision.

## 4. Planned Fix Proposal (Before Coding)

Provide:
- Problem summary
- Root-cause hypothesis
- Recommended fix approach
- Risks and alternatives
- Verification plan

Request confirmation before implementing this planned path.

## 5. Implementation and Validation

- Implement the smallest complete fix.
- Add regression tests that would catch recurrence.
- Run targeted tests first, then broader checks as needed.
- Verify no obvious regressions in adjacent behavior.

## 6. Completion Criteria

- Bug behavior resolved in reproducible scenario.
- Regression test exists and passes.
- Known risks and limitations documented.
