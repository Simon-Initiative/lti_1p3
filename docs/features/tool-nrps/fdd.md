# Functional Design Document

## 1. Design Overview
- Scope covered: Tool NRPS claim parsing, scope checks, pagination traversal, membership normalization.
- Assumptions:
  - Caller provides access tokens.
  - HTTP adapter remains configurable.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Tool.Services.NRPS` public APIs.
  - Endpoint/membership/page structs.
  - Scope policy, parser, client, and error normalization.
- Out-of-scope components:
  - Platform membership service behavior.
  - Persistent roster storage.

## 3. Architecture
- High-level flow:
  - Parse claim -> scope preflight -> request page -> parse memberships -> continue traversal when requested.
- Context/module responsibilities:
  - `Lti_1p3.Tool.Services.NRPS`
  - `Lti_1p3.Tool.Services.NRPS.ScopePolicy`
  - `Lti_1p3.Tool.Services.NRPS.Client`
  - `Lti_1p3.Tool.Services.NRPS.Parser`
  - `Lti_1p3.Tool.Services.NRPS.Errors`
- Supervision tree impact:
  - No new long-lived processes.

## 4. Data Design
- Schema changes: none.
- Data lifecycle: endpoint, page, and membership structs are request-scoped.
- Migration/backfill strategy: additive changes with notes for renamed helpers.

## 5. Interfaces and Contracts
- `from_launch_claim(claim_map) -> {:ok, %NrpsEndpoint{}} | {:error, error}`
- `list_memberships(endpoint, token, opts) -> {:ok, %MembershipPage{}} | {:error, error}`
- `stream_memberships(endpoint, token, opts) -> Enumerable.t()`
- `fetch_all_memberships(endpoint, token, opts) -> {:ok, [%Membership{}]} | {:error, error}`

## 6. Runtime Behavior
- Stateless operations safe for concurrency.
- Optional bounded retry for transient failures.
- Configurable timeout and max-page safeguards.

## 7. Security and Compliance
- Enforce `contextmembership.readonly` scope checks before requests.
- Optional PII field redaction in logs.
- Stable reason atoms for auth/validation failures.

## 8. Observability and Operations
- Metrics:
  - `tool_nrps.request.count`
  - `tool_nrps.page.count`
  - `tool_nrps.membership.count`
  - `tool_nrps.error.count`
- Logs: page index, member count, reason.
- Tracing: telemetry span around page fetch and parse.

## 9. Testing Strategy
- Unit: scope constants, link parser, role normalization, error mapping.
- Integration: multi-page traversal, filters, retries, and failures.
- End-to-end: launch claim to full roster retrieval flow.
- Load/failure: large roster traversal with max-page guards.

## 10. Open Questions
- Which helper boundaries are best for extraction after tool NRPS implementation (link parsing, filter normalization, error mapping)?
