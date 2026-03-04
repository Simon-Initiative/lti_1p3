# Manual QA Report - Core Feature

Date: 2026-03-03

## Environment

- Library: `lti_1p3`
- Test command validation: `mix test` (113 tests, 0 failures)

## Manual acceptance matrix

- Tool launch happy path: PASS (local verification via API and regression tests)
- Platform authorize redirect happy path: PASS (local verification via API and regression tests)
- Invalid state handling: PASS
- Nonce replay handling: PASS
- Wrong deployment handling: PASS
- Stale token handling: PASS

## External LMS / external tool sandbox checks

- Tool launch against external LMS sandbox: NOT EXECUTED in this environment
- Platform authorization against external tool sandbox: NOT EXECUTED in this environment

Reason: environment/network constraints in the current execution context.

## Remediation / follow-up

- Run external interoperability smoke tests in CI or maintainer environment with network access.
- Record external run evidence (request/response traces, outcome screenshots/logs).
