# Functional Design Document

## 1. Design Overview
- Scope covered: Complete AGS tool client surface, claim modeling, scope enforcement, and observability.
- Assumptions:
  - Core API refactor is available or implemented first.
  - HTTP client remains configurable via `Lti_1p3.Config`.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Tool.Services.AGS` public API redesign.
  - AGS structs: endpoint config, line item, score, result page.
  - Scope validator and error normalizer.
- Out-of-scope components:
  - Long-term storage of grades.
  - Platform-side AGS server implementation.

## 3. Architecture
- High-level flow:
  - Parse launch AGS claim -> validate scope -> build request -> execute HTTP -> decode/normalize response.
- Context/module responsibilities:
  - `Lti_1p3.Services.AGS`: operation entry points.
  - `Lti_1p3.Services.AGS.ScopePolicy`: scope-to-operation policy map.
  - `Lti_1p3.Services.AGS.Client`: HTTP and media-type handling.
  - `Lti_1p3.Services.AGS.Parser`: response decoding and pagination parsing.
- Supervision tree impact:
  - No new long-lived processes required.

## 4. Data Design
- Schema changes:
  - None in library core; optional metadata may be persisted by host app.
- Data lifecycle:
  - Access token is caller-supplied and short-lived.
  - AGS structs are ephemeral request/response data.
- Migration/backfill strategy:
  - Replace existing AGS structs with compatible field names where practical; provide migration notes for renamed fields.

## 5. Interfaces and Contracts
- Internal APIs:
  - `from_launch_claim(claim_map) -> {:ok, %AgsEndpoint{}} | {:error, error}`
  - `list_line_items(endpoint, token, opts) -> {:ok, %Page{items: [...], next: ...}} | {:error, error}`
  - `create_line_item(endpoint, token, attrs) -> {:ok, %LineItem{}} | {:error, error}`
  - `update_line_item(line_item_url, token, attrs) -> {:ok, %LineItem{}} | {:error, error}`
  - `delete_line_item(line_item_url, token) -> :ok | {:error, error}`
  - `post_score(line_item_url, token, %Score{}) -> :ok | {:error, error}`
  - `list_results(line_item_url, token, opts) -> {:ok, %Page{items: [%Result{}]}} | {:error, error}`
- External APIs/webhooks:
  - AGS HTTP endpoints from LMS (lineitems, scores, results).
- Event/message formats:
  - Error map includes `%{reason:, operation:, http_status:, retryable:, msg:}`.

## 6. Runtime Behavior
- Process model:
  - Stateless function calls per AGS operation.
- Concurrency model:
  - Safe for concurrent calls from caller processes.
- Failure handling/retries:
  - Retry policy optional and caller-configurable; defaults to no automatic write retry.
- Timeouts/circuit breakers:
  - Configurable request timeout and bounded retry delay.

## 7. Security and Compliance
- AuthN/AuthZ impact:
  - Enforce token scope per operation before HTTP call.
- Data protection:
  - Redact bearer tokens from logs and telemetry metadata.
- Audit/logging requirements:
  - Log operation names, endpoint host, status class, and reason category.

## 8. Observability and Operations
- Metrics:
  - `ags.request.count`, `ags.request.duration`, `ags.request.error_count`, `ags.scope.denied_count`.
- Logs:
  - Structured logs with operation and LMS host.
- Tracing:
  - Telemetry spans around each outbound AGS request.
- Alerts/runbooks:
  - Alert on sustained 5xx spikes or scope denial spikes.

## 9. Testing Strategy
- Unit:
  - Scope policy, media-type headers, error mapping, pagination parser.
- Integration:
  - Mocked LMS responses for all operations and edge cases.
- Contract:
  - Ensure operation-to-scope matrix tests are exhaustive.
- End-to-end:
  - Sample flow: launch -> token -> line item -> score -> results.
- Load/failure:
  - Repeated posting/list operations with intermittent failures.

## 10. Documentation Strategy
- ExDoc requirements:
  - Document all public AGS modules/functions with `@moduledoc`, `@doc`, and `@spec`.
  - Add examples for line item lifecycle, score publishing, and results retrieval.
- Supporting docs:
  - Keep AGS setup, scope mapping, LMS compatibility notes, and troubleshooting guides under `docs/`.
- Verification:
  - `mix docs` generation and docs completeness checks are required for merge.

## 11. Decisions
1. Optional streaming API for paged result traversal:
Decision: No.
Implementation impact: AGS will provide page-based (`list_results/3`) and eager aggregation paths only; no lazy `Stream`/`Enumerable` API will be added in this feature set.

2. Vendor compatibility policy centralization:
Decision: Yes.
Implementation impact: LMS-specific compatibility behavior will be centralized in a pluggable policy module (`Lti_1p3.Services.AGS.CompatibilityPolicy`) with a default strict policy and optional vendor profiles selected by configuration or runtime context.
