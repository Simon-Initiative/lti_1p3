# Product Requirements Document

## 1. Feature Summary
- Name: Tool AGS 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-05
- Status: Proposed

## 2. Problem Statement
- Current pain: Tool-side AGS behavior is partial and misses full line item, score, and result workflows.
- Why now: Certification readiness depends on complete, spec-aligned AGS client behavior.

### Current State Analysis
- `Lti_1p3.Tool.Services.AGS` provides partial operations.
- Scope enforcement is inconsistent per operation.
- Result pagination traversal is incomplete.
- Error metadata and tests are not complete across failure paths.

## 3. Goals and Non-Goals
### Goals
- Deliver full tool AGS operations for line items, scores, and results.
- Enforce operation-to-scope checks with stable reason atoms.
- Return typed structs and structured error maps for all public operations.
- Add telemetry and compatibility controls for LMS variance.
- Define reusable utility extraction points during tool implementation for later platform reuse.

### Non-Goals
- Platform-hosted AGS endpoint implementation.
- Library-managed persistent grade storage.

## 4. Users and Primary Use Cases
- Personas: Tool developers posting grades and reading results.
- Core scenarios:
  - Parse AGS launch claims and perform line item CRUD.
  - Post scores for a line item.
  - Retrieve results across pages.

## 5. Functional Requirements
1. Parse AGS claims into typed endpoint configuration.
2. Implement list/create/read/update/delete line item operations.
3. Implement score posting with payload validation.
4. Implement results retrieval with pagination traversal.
5. Enforce required scopes before outbound calls.
6. Return `%{reason:, operation:, http_status:, retryable:, msg:}` errors.
7. Emit telemetry for request outcomes and scope denials.
8. Document all public tool AGS APIs.
9. Identify duplicate-prone logic (headers, paging links, request normalization) and design it for extractable module boundaries.

## 6. Non-Functional Requirements
- Reliability: deterministic outcomes for identical inputs.
- Performance: low local overhead excluding network latency.
- Security/Compliance: token redaction and strict scope validation.
- Documentation: complete ExDoc and integration guide coverage.

## 7. Success Metrics
- Tool AGS conformance scenarios pass certification matrix.
- Interoperability verified with at least 2 LMS sandboxes.
- >= 90% coverage for tool AGS modules.
- Reusable utility candidates are documented with test coverage before platform AGS implementation starts.

## 8. Dependencies and Constraints
- Internal dependencies: token handling, HTTP transport abstraction, launch claim parsing.
- External dependencies: LMS AGS endpoint behavior variance.
- Constraints: framework-agnostic API design and stable tagged-tuple return shapes.

## 9. Risks and Mitigations
- Risk: LMS inconsistencies cause fragile integrations.
- Mitigation: compatibility profile options and explicit failure reason atoms.
- Risk: retries can duplicate writes.
- Mitigation: default no automatic retry for write operations.

## 10. Acceptance Criteria
1. Given valid AGS claims/scopes, all tool operations return typed success tuples.
2. Given insufficient scopes, operations return `{:error, %{reason: :insufficient_scope, ...}}`.
3. Given score publish requests, response handling is normalized.
4. Given result retrieval, pagination supports complete traversal.
5. Given docs generation, tool AGS API and guide docs are complete.
