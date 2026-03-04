# Product Requirements Document

## 1. Feature Summary
- Name: LTI AGS 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-03
- Status: Proposed

## 2. Problem Statement
- Current pain: AGS support exists but is partial and not fully spec-complete for robust production interoperability.
- Why now: Full LTI service coverage and certification readiness requires complete AGS behavior for tools and predictable integration points for platforms.

### Current State Analysis
- `Lti_1p3.Tool.Services.AGS` provides key operations but returns string errors with limited typed detail.
- Scope handling exists but contract does not uniformly enforce readonly/write scope distinctions for each endpoint.
- Result retrieval (`result.readonly`) behavior is missing from the current API.
- Pagination/link header handling and idempotent retry strategies are not explicitly modeled.
- Current tests emphasize happy path and basic failures but do not cover full AGS protocol matrix.

## 3. Goals and Non-Goals
### Goals
- Implement complete AGS 2.0 tool-side client features: line items, scores, and results.
- Provide structured request/response/error contracts with predictable tuple shapes.
- Add platform-facing helpers for validating AGS claims/scopes in launch context.
- Ensure AGS APIs align with the new unified core API style.
- Require comprehensive ExDoc and supporting AGS integration guides under `docs/`.

### Non-Goals
- Building a hosted gradebook or persistence store for AGS resources.
- Implementing LMS-specific custom AGS extensions.

## 4. Users and Primary Use Cases
- Personas: Tool developers posting scores; tool developers reading grade context; platform integrators validating AGS claims.
- Core scenarios:
  - Tool creates or finds a line item and posts user scores.
  - Tool retrieves line items/results with filtering and pagination.
  - Platform validates that AGS claim scopes match authorized capabilities.

## 5. Functional Requirements
1. Support AGS claim parsing into typed structs (endpoint, scopes, lineitem(s) URLs).
2. Support line item create/read/update/delete and list operations.
3. Support score publishing with spec-compliant media types and payload validation.
4. Support results retrieval (`result.readonly`) with pagination traversal.
5. Enforce scope requirements per operation and return explicit authorization errors.
6. Provide idempotent retry hooks and explicit transient/permanent failure categories.
7. Normalize API errors as reasoned maps instead of plain strings.
8. Add compatibility options for common LMS quirks (query limits, URL path variants).
9. Document all AGS public modules/functions with `@moduledoc`, `@doc`, `@spec`, and examples for main flows.
10. Publish/update AGS setup, scope, and interoperability guides under `docs/`.

## 6. Non-Functional Requirements
- Reliability: AGS operations must safely retry transient HTTP failures without duplicate side effects where applicable.
- Performance: P95 AGS client call overhead (excluding network) < 10ms.
- Security/Compliance: Access token scopes enforced per operation; no token leakage in logs.
- Observability: Telemetry per AGS operation with status, latency, LMS host, and reason category.
- Documentation: 100% AGS public API coverage in ExDoc and complete AGS guides in `docs/`.

## 7. Success Metrics
- Product metrics:
  - Pass AGS conformance scenarios in certification test plan.
  - Successful interoperability with at least 2 major LMS sandboxes.
- Technical metrics:
  - >= 90% AGS module coverage including error branches.
  - 100% operation-to-scope mapping tests passing.

## 8. Dependencies and Constraints
- Internal dependencies: Core API unification, access token module, shared HTTP client abstraction.
- External dependencies: LMS AGS endpoint availability and behavior differences.
- Constraints: Must remain framework-agnostic and persistence-agnostic.

## 9. Risks and Mitigations
- Risk: LMS-specific AGS endpoint inconsistencies cause brittle integrations.
- Mitigation: Add tolerant URL handling and configurable adapters for known quirks.
- Risk: Retry logic causes duplicate writes.
- Mitigation: Add idempotency guidance and caller-controlled retry policy for write operations.

## 10. Acceptance Criteria
1. Given valid AGS claim + scopes, when line item operations are invoked, then functions return typed success tuples and spec-compliant requests.
2. Given missing or insufficient scopes, when operation is invoked, then function returns `{:error, %{reason: :insufficient_scope, ...}}`.
3. Given valid scores payload and token, when score publish is invoked, then LMS response is normalized to a typed result.
4. Given results endpoint availability, when retrieving results, then pagination is supported and all pages can be consumed.
5. Given AGS failures (4xx/5xx/timeout), when operations fail, then error categories and retryability flags are explicit.
6. Given `mix docs` runs, when AGS docs are generated, then all public AGS modules/APIs and supporting guides are present and up to date.
