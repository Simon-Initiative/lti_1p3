# Manual QA Interoperability Report

## Date

- 2026-03-05

## Scope

- Platform AGS authorization (scope, deployment, context)
- Line item CRUD behavior
- Score ingestion and result retrieval behavior
- Denial/error-path behavior
- Shared AGS utility behavior across tool and platform scope policy paths

## Automated Validation Completed

1. `mix test`
- Result: pass (full suite)

2. `mix docs`
- Result: pass (ExDoc generation completed)

## Manual Reference Tool Validation

- Status: pending external execution.
- Required environments:
  1. IMS Reference Implementation tool
  2. Second reference tool/LMS integration path (for example Canvas developer key flow)

## Negative Paths Verified Locally

- Scope denial (`:insufficient_scope`).
- Deployment/context mismatch denials (`:invalid_deployment`, `:invalid_context`).
- Invalid attrs/options (`:invalid_attrs`, `:invalid_opts`).
- Not found/provider error mapping (`:not_found`, `:provider_error`).

## Findings and Ownership

- No critical local defects identified in AGS platform unit/integration-style tests.
- External interoperability validation remains required before feature closure.
- Owner: Lti_1p3 maintainers.
