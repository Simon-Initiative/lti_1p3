# Functional Design Document

## 1. Design Overview
- Scope covered: Platform NRPS authorization, membership retrieval orchestration, pagination/filter handling, observability.
- Assumptions:
  - Platform token and scope validation is available.
  - Tool NRPS implementation can provide extracted reusable helper modules.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Platform.Services.NRPS` public APIs.
  - Scope policy and filter validation.
  - Membership/page response normalization.
  - Adoption of extracted reusable modules for duplicate logic.
- Out-of-scope components:
  - Tool-side NRPS client behavior.
  - SIS synchronization pipelines.

## 3. Architecture
- High-level flow:
  - Receive membership request context -> authorize scope/context -> validate filters/page params -> retrieve memberships -> normalize response.
- Context/module responsibilities:
  - `Lti_1p3.Platform.Services.NRPS`
  - `Lti_1p3.Platform.Services.NRPS.ScopePolicy`
  - `Lti_1p3.Platform.Services.NRPS.Filters`
  - `Lti_1p3.Platform.Services.NRPS.Pagination`
  - `Lti_1p3.Platform.Services.NRPS.Errors`
  - Reused helpers extracted from tool implementation (for example: link parsing and parameter normalization).
- Supervision tree impact:
  - No new long-lived processes.

## 4. Data Design
- Schema changes: none in library core.
- Data lifecycle: request-scoped response structs with host-managed data retrieval.
- Migration/backfill strategy: additive API and module updates with migration notes if reusable helpers replace existing logic.

## 5. Interfaces and Contracts
- `authorize_request(claims, context) -> :ok | {:error, error}`
- `list_memberships(ctx, opts) -> {:ok, %MembershipPage{}} | {:error, error}`
- `validate_filters(opts, supported_filters) -> :ok | {:error, error}`
- `build_pagination_links(page_meta, opts) -> map()`

## 6. Runtime Behavior
- Stateless orchestration and concurrent-safe request handling.
- No implicit retries in read path.
- Configurable page-size limits and default ordering behavior.

## 7. Security and Compliance
- Scope/context/deployment checks prior to retrieval.
- PII redaction support in logs.
- Stable reason atoms for authorization and validation failures.

## 8. Observability and Operations
- Metrics:
  - `platform_nrps.request.count`
  - `platform_nrps.page.count`
  - `platform_nrps.denied.count`
  - `platform_nrps.error.count`
- Logs: context, filters, page parameters, result count, reason.
- Tracing: telemetry spans around authorization and retrieval.

## 9. Testing Strategy
- Unit: scope policy, filter validation, pagination link generation, error mapping.
- Integration: success, denial, invalid filter, and paging flows.
- End-to-end: tool-to-platform NRPS interoperability scenarios.
- Load/failure: high-volume pagination behavior.

## 10. Open Questions
- Which tool NRPS helper modules should be extracted before platform phase 2 to maximize reuse without premature abstraction?
