# Product Requirements Document

## 1. Feature Summary
- Name: LTI NRPS 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-03
- Status: Proposed

## 2. Problem Statement
- Current pain: NRPS support is currently minimal and does not provide complete pagination, filtering, role normalization, or robust error semantics.
- Why now: Full LTI service coverage and certification require spec-compliant roster retrieval behavior.

### Current State Analysis
- `Lti_1p3.Tool.Services.NRPS` currently fetches a single page using a hardcoded `limit` query append.
- `required_scopes/0` returns a claim key (`context_memberships_url`) rather than NRPS scope URL, which is a correctness issue.
- Service version compatibility and optional query parameters are not explicitly supported.
- Error handling is string-based and does not expose operation/status/retryability metadata.
- Tests cover only basic access and header shape, not full protocol semantics.

## 3. Goals and Non-Goals
### Goals
- Implement complete NRPS 2.0 tool-side client support with pagination and filtering.
- Enforce proper NRPS scope validation and claim parsing.
- Normalize memberships into typed structures with role helper utilities.
- Align NRPS API and errors with unified library conventions.
- Require full ExDoc coverage and NRPS operational guides in `docs/`.

### Non-Goals
- Persisting roster snapshots by default.
- Implementing institution-specific enrollment reconciliation logic.

## 4. Users and Primary Use Cases
- Personas: Tool developers synchronizing class rosters; platform integrators validating names/roles launch claims.
- Core scenarios:
  - Tool checks NRPS availability and scopes from launch claim.
  - Tool fetches full memberships list across all pages.
  - Tool filters memberships by role/status and maps standardized role helpers.

## 5. Functional Requirements
1. Parse NRPS claim into typed endpoint config including service version and URL.
2. Validate required NRPS scope URL(s) before outbound requests.
3. Retrieve memberships with support for paging via `Link` headers and query parameters.
4. Support optional role/limit/resourceLink filters where LMS supports them.
5. Normalize membership payload into typed structs with role helper conversion.
6. Return structured errors with reason atoms and retryability hints.
7. Provide convenience API for eager full-roster fetch and lazy page iteration.
8. Emit telemetry events for NRPS requests and pagination behavior.
9. Document all NRPS public modules/functions with `@moduledoc`, `@doc`, and `@spec`.
10. Add/update NRPS guides (setup, scope handling, pagination, and troubleshooting) under `docs/`.

## 6. Non-Functional Requirements
- Reliability: Full-roster retrieval should tolerate intermittent failures with controlled retry policy.
- Performance: Iterative pagination should avoid unbounded memory usage.
- Security/Compliance: Enforce scope validation and redact PII in logs by default.
- Observability: Track request count, page count, and failure reasons.
- Documentation: 100% NRPS public API ExDoc coverage and complete supporting docs in `docs/`.

## 7. Success Metrics
- Product metrics:
  - NRPS conformance scenarios pass in certification plan.
  - Successful roster retrieval across at least 2 LMS sandboxes.
- Technical metrics:
  - >= 90% NRPS module test coverage.
  - 100% validation tests for required scope URL correctness.

## 8. Dependencies and Constraints
- Internal dependencies: Core API refactor, shared HTTP utilities, role claim helpers.
- External dependencies: LMS NRPS pagination and filter behavior variance.
- Constraints: Must stay framework-agnostic and avoid mandatory persistence.

## 9. Risks and Mitigations
- Risk: LMS pagination implementations differ from spec.
- Mitigation: Implement tolerant parser with compatibility strategy toggles.
- Risk: Roster fetch can become large and memory-heavy.
- Mitigation: Provide streaming/page iterator API and caller-controlled accumulation.

## 10. Acceptance Criteria
1. Given valid NRPS claim and scope, when memberships are fetched, then API returns typed memberships and follows pagination links until completion.
2. Given invalid/missing NRPS scope, when request is attempted, then API returns `{:error, %{reason: :insufficient_scope, ...}}`.
3. Given multi-page responses, when using eager full fetch, then all pages are included exactly once.
4. Given filters are provided, when LMS supports them, then filtered results are returned.
5. Given NRPS failures (4xx/5xx/timeout), when operations fail, then structured error maps with retryability are returned.
6. Given `mix docs` runs, when NRPS docs are generated, then all NRPS public APIs are documented and referenced guides exist under `docs/`.
