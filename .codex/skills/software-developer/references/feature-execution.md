# Feature Execution Workflow

## 1. Intake and Alignment

- Read `prd.md`, `fdd.md`, and `plan.md` in that order when all are available.
- Extract:
- Feature scope and non-goals
- Acceptance criteria
- NFRs (performance, reliability, security, observability)
- Phase/task checklist expectations
- Flag ambiguities that block correct implementation.

## 2. Implementation Mapping

- Convert each plan task into concrete code/test/document updates.
- Identify dependencies and order work by critical path.
- Preserve architecture constraints defined by `fdd.md`.

## 3. Phase Execution

For each phase:
- Implement required code changes.
- Add or update automated tests.
- Run relevant quality checks.
- Mark completed checklist tasks in `plan.md` (`- [x]`) only after verification.

## 4. Verification Baseline

- Functional criteria satisfied.
- Regression risk reviewed for touched modules.
- NFR impacts considered and addressed.
- Operational concerns captured (migrations, rollout, monitoring, rollback).

## 5. Delivery Format

- Summarize implemented scope.
- List files changed and why.
- Report command-based verification results.
- Note remaining risks and follow-up tasks.
