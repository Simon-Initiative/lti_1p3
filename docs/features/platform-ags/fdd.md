# Functional Design Document

## 1. Design Overview
- Scope covered: Platform AGS authorization, operation orchestration, persistence integration, observability.
- Assumptions:
  - Platform token issuance and scope claims are available.
  - Tool AGS is implemented first and may provide extracted reusable helper modules.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Platform.Services.AGS` public APIs.
  - Authorization and error normalization modules.
  - Persistence integration boundary for line item/score/result storage.
  - Adoption of extracted reusable helper modules when duplication exists.
- Out-of-scope components:
  - Tool AGS HTTP client behavior.
  - Gradebook UI workflows.

## 3. Architecture
- High-level flow:
  - Receive AGS request context -> authorize operation -> execute storage/query operation -> normalize response.
- Context/module responsibilities:
  - `Lti_1p3.Platform.Services.AGS`
  - `Lti_1p3.Platform.Services.AGS.ScopePolicy`
  - `Lti_1p3.Platform.Services.AGS.Errors`
  - `Lti_1p3.Platform.Services.AGS.LineItems`
  - `Lti_1p3.Platform.Services.AGS.Scores`
  - `Lti_1p3.Platform.Services.AGS.Results`
  - Reused helpers extracted from tool implementation (for example: pagination link utilities, shared response mapping helpers).
- Supervision tree impact:
  - No new long-lived processes.

## 4. Data Design
- Schema changes: none in library core.
- Data lifecycle: platform operations work against host application data adapters.
- Migration/backfill strategy: provide migration notes when module/function names change due to utility extraction.

## 5. Interfaces and Contracts
- `authorize_operation(claims, operation, context) -> :ok | {:error, error}`
- `list_line_items(ctx, opts) -> {:ok, %Page{}} | {:error, error}`
- `create_line_item(ctx, attrs) -> {:ok, %LineItem{}} | {:error, error}`
- `update_line_item(ctx, id_or_url, attrs) -> {:ok, %LineItem{}} | {:error, error}`
- `delete_line_item(ctx, id_or_url) -> :ok | {:error, error}`
- `post_score(ctx, id_or_url, %Score{}) -> :ok | {:error, error}`
- `list_results(ctx, id_or_url, opts) -> {:ok, %Page{}} | {:error, error}`

## 6. Runtime Behavior
- Stateless orchestration with concurrent-safe request handling.
- No implicit write retries.
- Optional timeout configuration for adapter interactions.

## 7. Security and Compliance
- Scope/context/deployment checks before operation execution.
- Sensitive value redaction in structured logs.
- Stable reason atoms for authorization and validation paths.

## 8. Observability and Operations
- Metrics:
  - `platform_ags.request.count`
  - `platform_ags.denied.count`
  - `platform_ags.error.count`
- Logs: operation, deployment/context, status class, reason.
- Tracing: telemetry spans around authorization and operation execution.

## 9. Testing Strategy
- Unit: scope policy, error mapping, response normalization.
- Integration: line item/score/result success and denial flows.
- End-to-end: tool-to-platform AGS interoperability scenarios.
- Load/failure: concurrent requests and timeout handling.

## 10. Open Questions
- Which extracted tool utilities are stable enough to promote before platform AGS phase 2 starts?
