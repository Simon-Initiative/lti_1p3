# Product Requirements Document

## 1. Feature Summary
- Name: Tool NRPS 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-04
- Status: Proposed

## 2. Problem Statement
- Current pain: Tool NRPS support is incomplete for scope correctness, paging, and filtering.
- Why now: Tool roster synchronization requires spec-compliant NRPS behavior for certification.

### Current State Analysis
- Current client is single-page oriented and appends fixed limits.
- Required scope handling has correctness gaps.
- Error handling lacks typed reason metadata.
- Tests do not fully cover pagination/filter and failure semantics.

## 3. Goals and Non-Goals
### Goals
- Deliver complete tool NRPS retrieval with pagination and filter support.
- Correct and enforce required NRPS scope URL checks.
- Normalize memberships to typed structs with role helpers.
- Provide page, stream, and eager-fetch APIs.
- Publish complete ExDoc and NRPS tool guides.

### Non-Goals
- Built-in roster persistence.
- Institution-specific enrollment reconciliation workflows.

## 4. Users and Primary Use Cases
- Personas: Tool developers reading class rosters.
- Core scenarios:
  - Parse NRPS launch claims and validate scopes.
  - Fetch memberships across pages.
  - Filter by supported role/status/resource-link options.

## 5. Functional Requirements
1. Parse NRPS claim into typed endpoint config.
2. Validate required NRPS scope URLs per operation.
3. Support `Link` header page traversal.
4. Support optional filter/query parameters.
5. Normalize memberships to typed structs.
6. Provide stream and eager full-fetch helpers.
7. Return structured error maps with retryability hints.
8. Emit telemetry for requests, pages, and failures.
9. Document all public NRPS tool modules/functions.
10. Add/update NRPS tool guides under `docs/`.

## 6. Non-Functional Requirements
- Reliability: bounded retry policy for transient failures.
- Performance: avoid unbounded memory growth on large rosters.
- Security/Compliance: scope enforcement and optional PII redaction.
- Documentation: full ExDoc and guide coverage.

## 7. Success Metrics
- Tool NRPS conformance scenarios pass certification matrix.
- Roster retrieval succeeds across at least 2 LMS sandboxes.
- >= 90% coverage for tool NRPS modules.

## 8. Dependencies and Constraints
- Internal: shared HTTP utilities, role helpers, unified error conventions.
- External: LMS pagination/filter differences.
- Constraints: framework-agnostic and persistence-agnostic.

## 9. Risks and Mitigations
- Risk: LMS pagination variance.
- Mitigation: tolerant `Link` parser and compatibility policy hooks.
- Risk: large roster memory pressure.
- Mitigation: page-streaming API and max-page safeguards.

## 10. Acceptance Criteria
1. Given valid claim/scope, tool retrieves memberships across all pages.
2. Given missing/invalid scope, API returns `:insufficient_scope` errors.
3. Given filters, supported LMS returns filtered memberships.
4. Given failures, structured errors include operation/status/retryability metadata.
5. Given `mix docs`, tool NRPS docs are complete and current.
