# Functional Design Document

## 1. Design Overview
- Scope covered: Platform AGS authorization, endpoint/service behavior, provider contracts, observability.
- Assumptions:
  - Platform token issuance and scope claims are available.
  - Host app supplies persistence adapters via behaviors.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Platform.Services.AGS` APIs and endpoint helpers.
  - AGS provider behavior contracts for line items/scores/results.
  - Scope policy and error mapping.
- Out-of-scope components:
  - Turnkey gradebook UI.
  - Tool-side AGS HTTP client behavior.

## 3. Architecture
- High-level flow:
  - Receive AGS request -> authenticate token -> authorize scope/context/deployment -> provider operation -> normalize response.
- Module responsibilities:
  - `Lti_1p3.Platform.Services.AGS`: entry point and orchestration.
  - `Lti_1p3.Platform.Services.AGS.ScopePolicy`: required scope checks.
  - `Lti_1p3.Platform.Services.AGS.Provider`: behavior contract.
  - `Lti_1p3.Platform.Services.AGS.Errors`: reason + HTTP status mapping.

## 4. Data Design
- Schema changes: none in library core.
- Data lifecycle: persistence delegated to host adapters.
- Migration strategy: clear contract versioning notes for provider implementers.

## 5. Interfaces and Contracts
- `authorize_operation(claims, operation, context) -> :ok | {:error, error}`
- `list_line_items(ctx, opts) -> {:ok, %Page{}} | {:error, error}`
- `create_line_item(ctx, attrs) -> {:ok, %LineItem{}} | {:error, error}`
- `update_line_item(ctx, id_or_url, attrs) -> {:ok, %LineItem{}} | {:error, error}`
- `delete_line_item(ctx, id_or_url) -> :ok | {:error, error}`
- `post_score(ctx, id_or_url, %Score{}) -> :ok | {:error, error}`
- `list_results(ctx, id_or_url, opts) -> {:ok, %Page{}} | {:error, error}`

## 6. Runtime Behavior
- Stateless orchestration; host adapter handles storage side effects.
- Supports concurrent requests with adapter-level transaction controls.
- No implicit retries for writes.

## 7. Security and Compliance
- Token scope and deployment/context checks before provider calls.
- Structured audit logs for authorization decisions and mutations.
- Sensitive identifiers redacted in configurable logging mode.

## 8. Observability and Operations
- Metrics: `platform_ags.request.count`, `platform_ags.denied.count`, `platform_ags.error.count`.
- Logs: operation, deployment, scope result, status class.
- Tracing: telemetry spans around orchestration and provider invocation.

## 9. Testing Strategy
- Unit: scope policy, error mapping, contract validation helpers.
- Contract: provider behavior test suite for adapters.
- Integration: endpoint helpers across success and denial paths.
- End-to-end: tool-to-platform AGS interoperability scenario.

## 10. Documentation Strategy
- ExDoc for all platform AGS public modules and behaviors.
- Guides for provider implementation, scope mapping, and endpoint integration.
- Merge gate includes `mix docs` and contract docs review.

## 11. Decisions
1. Persistence ownership:
Decision: persistence remains adapter-owned via behavior contract.
Implementation impact: no default persistent store in library core.

2. Scope enforcement location:
Decision: enforce centrally before provider invocation.
Implementation impact: adapters assume pre-authorized operations.
