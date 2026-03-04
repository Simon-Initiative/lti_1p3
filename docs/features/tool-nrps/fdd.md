# Functional Design Document

## 1. Design Overview
- Scope covered: Tool NRPS claim parsing, scope policy, pagination, filters, membership normalization.
- Assumptions:
  - Caller provides access tokens.
  - Shared telemetry/error conventions are available.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Tool.Services.NRPS` API redesign.
  - Endpoint/membership/page structs and role normalizers.
  - Scope policy, parser, and client modules.
- Out-of-scope components:
  - Platform-side NRPS service implementation.
  - Roster persistence jobs.

## 3. Architecture
- High-level flow:
  - Parse claim -> validate scope -> request page -> parse memberships -> follow next links as requested.
- Module responsibilities:
  - `Lti_1p3.Tool.Services.NRPS`
  - `Lti_1p3.Tool.Services.NRPS.ScopePolicy`
  - `Lti_1p3.Tool.Services.NRPS.Client`
  - `Lti_1p3.Tool.Services.NRPS.Parser`

## 4. Data Design
- Schema changes: none.
- Data lifecycle: endpoint and memberships are request-scoped unless caller persists.
- Migration strategy: migration notes for corrected scope constants and renamed helpers.

## 5. Interfaces and Contracts
- `from_launch_claim(claim_map) -> {:ok, %NrpsEndpoint{}} | {:error, error}`
- `list_memberships(endpoint, token, opts) -> {:ok, %MembershipPage{}} | {:error, error}`
- `stream_memberships(endpoint, token, opts) -> Enumerable.t()`
- `fetch_all_memberships(endpoint, token, opts) -> {:ok, [%Membership{}]} | {:error, error}`

## 6. Runtime Behavior
- Stateless calls and streaming traversal helpers.
- Bounded retry for transient page fetch failures.
- Configurable timeout and max-page safeguards.

## 7. Security and Compliance
- Enforce `contextmembership.readonly` scope checks preflight.
- Optional redaction of PII fields in logs.
- Structured audit logs by operation and host.

## 8. Observability and Operations
- Metrics: `tool_nrps.request.count`, `tool_nrps.page.count`, `tool_nrps.membership.count`, `tool_nrps.error.count`.
- Logs: page index, result size, reason category on failure.
- Tracing: telemetry span around each page fetch.

## 9. Testing Strategy
- Unit: scope constants, link parser, role normalization.
- Integration: multi-page traversal, filters, retry behavior.
- Contract: claim parsing and required scope invariants.
- End-to-end: launch claim to full roster retrieval.

## 10. Documentation Strategy
- ExDoc for all public NRPS tool modules/functions.
- Guides for setup, pagination, filters, and troubleshooting.
- Merge gate includes docs generation and example validation.

## 11. Decisions
1. Deduplication policy:
Decision: no built-in deduplication.
Implementation impact: preserve source response ordering/content.

2. Stream API behavior:
Decision: stream over pages, not individual members by default.
Implementation impact: predictable paging semantics and lower coordination overhead.
