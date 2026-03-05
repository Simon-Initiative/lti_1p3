# Manual QA Interoperability Report

## Date

- 2026-03-05

## Scope

- AGS launch claim parsing and scope preflight
- Line item CRUD behavior
- Score publish behavior
- Results pagination and fetch-all traversal
- Error and denial-path behavior

## Automated Validation Completed

1. `mix test`
- Result: pass (full suite)

2. `mix docs`
- Result: pass (ExDoc generation completed)

## Manual LMS Sandbox Validation

- Status: pending external execution.
- Required environments:
  1. IMS Reference Implementation sandbox
  2. Second LMS sandbox (for example Canvas)

## Negative Paths Verified Locally

- Scope denial (`:insufficient_scope`).
- Invalid attrs/payload/filter validation (`:invalid_attrs`, `:invalid_payload`, `:invalid_filter`).
- HTTP and transport failures with retryability metadata (`:request_failed`, `:transport_error`).
- Max-page guard on results traversal (`:max_pages_exceeded`).

## Findings and Ownership

- No critical local defects identified in AGS unit/integration-style tests.
- External interoperability validation remains required before feature closure.
- Owner: Lti_1p3 maintainers.
