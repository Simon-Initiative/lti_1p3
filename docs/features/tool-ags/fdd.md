# Functional Design Document

## 1. Design Overview
- Scope covered: Tool-side AGS claim parsing, scope enforcement, client operations, error normalization, observability.
- Assumptions:
  - Unified error/telemetry conventions are available.
  - HTTP client adapter remains configurable.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Tool.Services.AGS` API redesign.
  - AGS endpoint/line item/score/result/page structs.
  - Scope policy, parser, compatibility policy, and error mapper.
- Out-of-scope components:
  - Platform-hosted AGS endpoints.
  - Grade persistence.

## 3. Architecture
- High-level flow:
  - Parse AGS claim -> preflight scope check -> build request -> execute HTTP -> parse/normalize response.
- Module responsibilities:
  - `Lti_1p3.Tool.Services.AGS`: public entry points.
  - `Lti_1p3.Tool.Services.AGS.ScopePolicy`: operation-to-scope matrix.
  - `Lti_1p3.Tool.Services.AGS.Client`: request construction and transport integration.
  - `Lti_1p3.Tool.Services.AGS.Parser`: payload and pagination parsing.
  - `Lti_1p3.Tool.Services.AGS.CompatibilityPolicy`: vendor profile behavior.

## 4. Data Design
- Schema changes: none.
- Data lifecycle: endpoint config and response structs are request-scoped.
- Migration strategy: stable return tuple shapes; migration notes for renamed fields.

## 5. Interfaces and Contracts
- `from_launch_claim(claim_map) -> {:ok, %AgsEndpoint{}} | {:error, error}`
- `list_line_items(endpoint, token, opts) -> {:ok, %Page{}} | {:error, error}`
- `create_line_item(endpoint, token, attrs) -> {:ok, %LineItem{}} | {:error, error}`
- `update_line_item(line_item_url, token, attrs) -> {:ok, %LineItem{}} | {:error, error}`
- `delete_line_item(line_item_url, token) -> :ok | {:error, error}`
- `post_score(line_item_url, token, %Score{}) -> :ok | {:error, error}`
- `list_results(line_item_url, token, opts) -> {:ok, %Page{}} | {:error, error}`

## 6. Runtime Behavior
- Stateless calls safe for concurrency.
- Retry behavior is optional and caller-configurable.
- Configurable request timeout and bounded backoff.

## 7. Security and Compliance
- Strict preflight scope checks per operation.
- Token and sensitive payload redaction in logs/telemetry.
- Structured reason atoms for all authorization and validation failures.

## 8. Observability and Operations
- Metrics: `ags.request.count`, `ags.request.duration`, `ags.error.count`, `ags.scope.denied.count`.
- Structured logs include operation, host, status class, and reason.
- Telemetry spans around each outbound AGS request.

## 9. Testing Strategy
- Unit: scope matrix, media types, parser, error mapping.
- Integration: CRUD, scores, results, pagination, and failure branches.
- Contract: exhaustive operation-to-scope tests.
- End-to-end: launch claim to score and result retrieval flow.

## 10. Documentation Strategy
- ExDoc on all public AGS tool modules and functions.
- Guides under `docs/` for setup, scopes, operations, compatibility notes.
- Merge gate includes `mix docs` and guide completeness checks.

## 11. Decisions
1. Pagination API shape:
Decision: page-first API with optional helper for eager traversal.
Implementation impact: maintain deterministic paging behavior and avoid implicit full accumulation.

2. Retry defaults for writes:
Decision: writes default to no automatic retry.
Implementation impact: callers opt in explicitly when idempotency guarantees are acceptable.
