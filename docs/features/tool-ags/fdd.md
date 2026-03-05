# Functional Design Document

## 1. Design Overview
- Scope covered: Tool AGS claim parsing, scope checks, request/response normalization, observability.
- Assumptions:
  - Caller provides access tokens.
  - HTTP adapter remains configurable.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Tool.Services.AGS` public APIs.
  - Typed AGS structs (endpoint, line item, score, result, page).
  - Scope policy, parser, compatibility policy, and error normalization.
- Out-of-scope components:
  - Platform AGS endpoint service behavior.
  - Persistent grade storage.

## 3. Architecture
- High-level flow:
  - Parse AGS claim -> scope preflight -> build HTTP request -> execute transport -> normalize payload.
- Context/module responsibilities:
  - `Lti_1p3.Tool.Services.AGS`
  - `Lti_1p3.Tool.Services.AGS.ScopePolicy`
  - `Lti_1p3.Tool.Services.AGS.Client`
  - `Lti_1p3.Tool.Services.AGS.Parser`
  - `Lti_1p3.Tool.Services.AGS.Errors`
  - `Lti_1p3.Tool.Services.AGS.CompatibilityPolicy`
- Supervision tree impact:
  - No new long-lived processes.

## 4. Data Design
- Schema changes: none.
- Data lifecycle: endpoint config and parsed payload structs are request-scoped.
- Migration/backfill strategy: additive APIs with migration notes for renamed helpers.

## 5. Interfaces and Contracts
- `from_launch_claim(claim_map) -> {:ok, %AgsEndpoint{}} | {:error, error}`
- `list_line_items(endpoint, token, opts) -> {:ok, %Page{}} | {:error, error}`
- `create_line_item(endpoint, token, attrs) -> {:ok, %LineItem{}} | {:error, error}`
- `update_line_item(line_item_url, token, attrs) -> {:ok, %LineItem{}} | {:error, error}`
- `delete_line_item(line_item_url, token) -> :ok | {:error, error}`
- `post_score(line_item_url, token, %Score{}) -> :ok | {:error, error}`
- `list_results(line_item_url, token, opts) -> {:ok, %Page{}} | {:error, error}`

## 6. Runtime Behavior
- Stateless, concurrent-safe operations.
- Optional caller-configured retry policy.
- Configurable timeout and bounded backoff.

## 7. Security and Compliance
- Required scope checks before outbound calls.
- Redaction of bearer tokens in logs and telemetry metadata.
- Stable reason atoms for authorization and validation failures.

## 8. Observability and Operations
- Metrics:
  - `tool_ags.request.count`
  - `tool_ags.request.duration`
  - `tool_ags.error.count`
  - `tool_ags.scope.denied.count`
- Logs: operation, host, status class, reason.
- Tracing: telemetry span per AGS request.

## 9. Testing Strategy
- Unit: scope policy, parsers, error mapping, compatibility policy.
- Integration: line item/score/result flows with success and failure paths.
- End-to-end: launch claim to score publish and result retrieval flow.
- Load/failure: timeout and transient failure classification.

## 10. Open Questions
- Which utility namespace will host extracted HTTP/pagination helpers after tool implementation proves duplication (`Lti_1p3.Services.Common.*` vs `Lti_1p3.Internal.*`)?
