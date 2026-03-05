# Product Requirements Document

## 1. Feature Summary
- Name: Tool NRPS 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-05
- Status: Proposed

## 2. Problem Statement
- Current pain: Tool NRPS behavior is incomplete for scope correctness, filtering, and page traversal.
- Why now: Certification and production roster synchronization require complete NRPS behavior.

### Current State Analysis
- Current implementation is single-page oriented.
- Scope handling needs stricter correctness.
- Error shapes and retry metadata are inconsistent.
- Coverage is incomplete across pagination and filter paths.

## 3. Goals and Non-Goals
### Goals
- Deliver full tool NRPS retrieval with pagination and filter support.
- Enforce required NRPS scopes per operation.
- Normalize memberships into typed structures.
- Provide page, stream, and eager full-fetch APIs.
- Define reusable module extraction points during tool implementation for platform reuse.

### Non-Goals
- Built-in roster persistence.
- Institution-specific roster reconciliation workflows.

## 4. Users and Primary Use Cases
- Personas: Tool developers retrieving class rosters.
- Core scenarios:
  - Parse NRPS launch claims and validate scopes.
  - Fetch memberships across pages.
  - Apply supported role/status/resource-link filters.

## 5. Functional Requirements
1. Parse NRPS launch claim into typed endpoint configuration.
2. Validate required NRPS scopes before requests.
3. Support `Link` header traversal for multi-page responses.
4. Support optional query filters and limits.
5. Normalize memberships to typed structs.
6. Provide stream and eager fetch-all APIs.
7. Return structured errors with retryability hints.
8. Emit telemetry for requests, pages, and failures.
9. Document all public tool NRPS APIs.
10. Identify duplicate-prone logic and define extractable boundaries for later platform reuse.

## 6. Non-Functional Requirements
- Reliability: deterministic paging behavior and bounded retries.
- Performance: avoid unbounded memory growth on large rosters.
- Security/Compliance: strict scope checks and configurable PII redaction.
- Documentation: complete ExDoc and guide coverage.

## 7. Success Metrics
- Tool NRPS conformance scenarios pass certification matrix.
- Interoperability verified with at least 2 LMS sandboxes.
- >= 90% coverage for tool NRPS modules.
- Reusable utility candidates are documented and tested before platform NRPS implementation starts.

## 8. Dependencies and Constraints
- Internal dependencies: launch claims, HTTP transport, role helpers.
- External dependencies: LMS pagination/filter differences.
- Constraints: framework-agnostic API design and stable tagged-tuple shapes.

## 9. Risks and Mitigations
- Risk: LMS pagination variance causes brittle traversal.
- Mitigation: tolerant parser with explicit failure reasons.
- Risk: large rosters increase memory pressure.
- Mitigation: stream API and max-page guardrails.

## 10. Acceptance Criteria
1. Given valid claim/scope, tool retrieves memberships across pages.
2. Given missing scope, APIs return `:insufficient_scope` errors.
3. Given supported filters, memberships are filtered as requested.
4. Given failures, structured errors include operation/status/retryability.
5. Given docs generation, tool NRPS API and guide docs are complete.
