# Manual QA Interoperability Report

## Date

- 2026-03-05

## Scope

- Tool deep-linking request validation
- Content item creation
- Deep-linking response JWT generation/signing
- Negative-path behavior

## Automated Validation Completed

1. `mix test`
- Result: pass (`122 tests, 0 failures`)

2. `mix docs`
- Result: pass (documentation generated)

## Manual LMS Sandbox Validation

- Status: pending external execution.
- Required environments:
  1. IMS Reference Implementation (tool launch + deep-link return)
  2. Second LMS sandbox (for example Canvas test instance)

## Negative Paths Verified Locally

- Missing/invalid deep-linking settings claim handling.
- Unsupported content item types.
- Compatibility filtering behaviors.
- Signing key absence and invalid content item list handling.

## Findings and Ownership

- No critical local defects found in automated tests.
- Outstanding manual interoperability execution is required before feature closure.
- Owner: Lti_1p3 maintainers.
