# Product Requirements Document

## 1. Feature Summary
- Name: Tool AGS 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-04
- Status: Proposed

## 2. Problem Statement
- Current pain: Tool-side AGS behavior is partial and misses full line item, score, and result workflows.
- Why now: Tool certification readiness depends on a complete, spec-aligned AGS client surface.

### Current State Analysis
- `Lti_1p3.Tool.Services.AGS` provides partial operations with string-based errors.
- Scope enforcement is inconsistent per operation.
- `result.readonly` retrieval and pagination traversal are incomplete.
- Tests do not cover the full AGS protocol matrix.

## 3. Goals and Non-Goals
### Goals
- Deliver complete tool-side AGS operations for line items, scores, and results.
- Enforce operation-to-scope checks with explicit, stable error reasons.
- Return typed structs and structured error maps for all public operations.
- Add telemetry, retry classification hooks, and interoperability compatibility controls.
- Publish complete ExDoc and AGS integration guides.

### Non-Goals
- Implementing a platform-hosted AGS service in this feature.
- Persisting grades in library-managed storage.

## 4. Users and Primary Use Cases
- Personas: Tool developers posting grades and reading result context.
- Core scenarios:
  - Parse AGS launch claims and list/create/update/delete line items.
  - Post scores to line items.
  - Retrieve results across pages.

## 5. Functional Requirements
1. Parse AGS claim into typed endpoint configuration.
2. Implement list/create/read/update/delete line item operations.
3. Implement score posting with payload validation.
4. Implement results retrieval with pagination traversal.
5. Enforce required scopes before outbound calls.
6. Return structured errors: `%{reason:, operation:, http_status:, retryable:, msg:}`.
7. Add compatibility policy hooks for LMS-specific AGS behavior.
8. Emit telemetry for request outcomes and scope denials.
9. Document all public tool AGS APIs.
10. Add/update AGS tool integration guides under `docs/`.

## 6. Non-Functional Requirements
- Reliability: bounded retry support for transient failures with caller control.
- Performance: low library overhead (<10ms local processing excluding network).
- Security/Compliance: bearer token redaction and strict scope validation.
- Documentation: full public API docs coverage and operational guides.

## 7. Success Metrics
- AGS tool conformance scenarios pass in certification matrix.
- Interoperability verified with at least 2 LMS sandboxes.
- >= 90% coverage for AGS tool modules and error paths.

## 8. Dependencies and Constraints
- Internal: access token handling, HTTP client abstraction, unified error contracts.
- External: LMS AGS endpoint and media-type behavior variance.
- Constraints: framework-agnostic, persistence-agnostic API design.

## 9. Risks and Mitigations
- Risk: LMS inconsistencies cause fragile integrations.
- Mitigation: centralized compatibility policy with configurable profiles.
- Risk: retries can duplicate writes.
- Mitigation: default no automatic write retry; caller-explicit retry policies.

## 10. Acceptance Criteria
1. Given valid AGS claims/scopes, tool operations return typed success tuples and spec-compliant requests.
2. Given insufficient scopes, operations return `{:error, %{reason: :insufficient_scope, ...}}`.
3. Given score publish requests, responses are normalized to typed results/errors.
4. Given result retrieval, pagination supports complete page traversal.
5. Given 4xx/5xx/timeout failures, errors include explicit reason and retryability metadata.
6. Given `mix docs`, tool AGS public APIs and guides are complete and current.
