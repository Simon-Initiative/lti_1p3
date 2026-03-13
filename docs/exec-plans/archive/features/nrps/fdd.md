# Functional Design Document

## 1. Design Overview
- Scope covered: NRPS claim parsing, scope policy, paginated memberships client, typed membership modeling.
- Assumptions:
  - Core error contract and telemetry conventions are available.
  - Caller supplies valid access token with relevant scope.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Tool.Services.NRPS` public API redesign.
  - `Membership` and `MembershipPage` models.
  - NRPS scope and claim validators.
- Out-of-scope components:
  - Roster persistence or synchronization jobs.
  - Platform-side NRPS server implementation.

## 3. Architecture
- High-level flow:
  - Parse launch NRPS claim -> validate scope -> request first page -> follow `Link: rel=next` until complete.
- Context/module responsibilities:
  - `Lti_1p3.Services.NRPS`: entry point operations.
  - `Lti_1p3.Services.NRPS.ScopePolicy`: scope enforcement.
  - `Lti_1p3.Services.NRPS.Client`: HTTP requests + pagination headers.
  - `Lti_1p3.Services.NRPS.Parser`: membership decoding and normalization.
- Supervision tree impact:
  - No new OTP workers required.

## 4. Data Design
- Schema changes:
  - None in core library.
- Data lifecycle:
  - Membership data exists in-memory for request lifecycle unless caller persists externally.
- Migration/backfill strategy:
  - Provide migration notes for renamed helpers and corrected required scopes.

## 5. Interfaces and Contracts
- Internal APIs:
  - `from_launch_claim(claim_map) -> {:ok, %NrpsEndpoint{}} | {:error, error}`
  - `list_memberships(endpoint, token, opts) -> {:ok, %MembershipPage{}} | {:error, error}`
  - `stream_memberships(endpoint, token, opts) -> Enumerable.t()`
  - `fetch_all_memberships(endpoint, token, opts) -> {:ok, [%Membership{}]} | {:error, error}`
- External APIs/webhooks:
  - NRPS `context_memberships_url` endpoint.
- Event/message formats:
  - Error map: `%{reason:, operation:, http_status:, retryable:, msg:}`.

## 6. Runtime Behavior
- Process model:
  - Stateless function calls and enumerables.
- Concurrency model:
  - Supports parallel roster requests across different contexts.
- Failure handling/retries:
  - Bounded retry for transient failures; no silent partial success.
- Timeouts/circuit breakers:
  - Configurable request timeout and max pages safety guard.

## 7. Security and Compliance
- AuthN/AuthZ impact:
  - Validate `https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly` before call.
- Data protection:
  - Optional redaction of email/name/picture fields in logs.
- Audit/logging requirements:
  - Log request host, page index, result size, and error categories.

## 8. Observability and Operations
- Metrics:
  - `nrps.request.count`, `nrps.page.count`, `nrps.membership.count`, `nrps.error.count`.
- Logs:
  - Structured page-level and aggregate fetch logs.
- Tracing:
  - Telemetry spans around each page retrieval.
- Alerts/runbooks:
  - Alert when page traversal failures exceed threshold.

## 9. Testing Strategy
- Unit:
  - Scope validation, link header parser, role normalization helpers.
- Integration:
  - Multi-page mocked NRPS responses, filter behaviors, retries.
- Contract:
  - Required scope constants and claim parsing invariants.
- End-to-end:
  - Launch -> token -> roster retrieval flow.
- Load/failure:
  - Large roster paging and intermittent timeout simulation.

## 10. Documentation Strategy
- ExDoc requirements:
  - Document all public NRPS modules/functions with `@moduledoc`, `@doc`, and `@spec`.
  - Include examples for page fetch, streaming, and full-roster retrieval.
- Supporting docs:
  - Maintain NRPS setup, scope, pagination, and troubleshooting guides under `docs/`.
- Verification:
  - `mix docs` generation and docs completeness checks are required for merge.

## 11. Decisions
1. Deduplication strategy for repeated members across pages:
Decision: No built-in deduplication strategy.
Implementation impact: NRPS pagination APIs will preserve source ordering/content as returned by the LMS; callers that need deduplication can apply it explicitly in their application layer.

2. Role helper conversion output model:
Decision: Use existing role structs with NRPS-specific normalization.
Implementation impact: role conversion helpers should normalize NRPS role claims into the current shared role structs rather than introducing dedicated NRPS enum types.
