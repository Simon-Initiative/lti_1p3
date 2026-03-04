# Functional Design Document

## 1. Design Overview
- Scope covered: Platform NRPS authorization, membership service orchestration, provider contracts, observability.
- Assumptions:
  - Platform token and scope validation is available.
  - Host app implements membership provider behavior.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Platform.Services.NRPS` public APIs.
  - Provider behaviors for membership retrieval.
  - Pagination and filter validation logic.
- Out-of-scope components:
  - Tool-side NRPS client.
  - SIS sync and roster reconciliation jobs.

## 3. Architecture
- High-level flow:
  - Receive request -> authenticate/authorize scope and context -> provider membership lookup -> paginate/map response -> return normalized payload.
- Module responsibilities:
  - `Lti_1p3.Platform.Services.NRPS`
  - `Lti_1p3.Platform.Services.NRPS.ScopePolicy`
  - `Lti_1p3.Platform.Services.NRPS.Provider`
  - `Lti_1p3.Platform.Services.NRPS.Pagination`

## 4. Data Design
- Schema changes: none in library core.
- Data lifecycle: provider adapter owns data retrieval and persistence concerns.
- Migration strategy: adapter migration notes for contract additions.

## 5. Interfaces and Contracts
- `authorize_request(claims, context) -> :ok | {:error, error}`
- `list_memberships(ctx, opts) -> {:ok, %MembershipPage{}} | {:error, error}`
- `validate_filters(opts, capability) -> :ok | {:error, error}`
- Provider callbacks for filtered page retrieval and count metadata.

## 6. Runtime Behavior
- Stateless orchestration module with adapter callback delegation.
- Concurrent safe request handling.
- No implicit retries in mutation-free read path.

## 7. Security and Compliance
- Scope/context/deployment checks before provider calls.
- PII redaction support in logs.
- Structured audit logs for denials and high-volume access.

## 8. Observability and Operations
- Metrics: `platform_nrps.request.count`, `platform_nrps.page.count`, `platform_nrps.denied.count`, `platform_nrps.error.count`.
- Logs: context, page params, result count, failure reason.
- Tracing: telemetry spans for authorization and provider query operations.

## 9. Testing Strategy
- Unit: scope policy, filter validation, pagination metadata.
- Contract: provider behavior test suite.
- Integration: endpoint helper success, denial, and invalid filter flows.
- End-to-end: tool calls platform NRPS and consumes paginated responses.

## 10. Documentation Strategy
- ExDoc for platform NRPS modules and behaviors.
- Guides for adapter implementation and endpoint integration.
- Merge gate includes docs generation and contract docs verification.

## 11. Decisions
1. Default filter behavior:
Decision: reject unsupported filters with explicit reason.
Implementation impact: avoids silent mismatches and increases predictability.

2. Pagination token model:
Decision: support offset/page semantics with adapter-defined translation.
Implementation impact: host adapters can map to native datastore paging mechanisms.
