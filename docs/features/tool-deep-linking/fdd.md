# Functional Design Document

## 1. Design Overview
- Scope covered: Tool deep-link request validation, settings parsing, content item modeling, response signing.
- Assumptions:
  - Launch dispatch supports deep-link message routing.
  - Signing key retrieval utilities are available.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Tool.DeepLinking.RequestValidator`
  - `Lti_1p3.Tool.DeepLinking.Settings`
  - `Lti_1p3.Tool.DeepLinking.ContentItem`
  - `Lti_1p3.Tool.DeepLinking.ResponseBuilder`
  - `Lti_1p3.Tool.DeepLinking.Errors`
- Out-of-scope components:
  - Platform deep-link response validation.
  - Tool authoring UI behavior.

## 3. Architecture
- High-level flow:
  - Validate launch claims -> parse settings -> validate/build content items -> assemble/sign response JWT.
- Context/module responsibilities:
  - `Lti_1p3.Tool.DeepLinking.RequestValidator`
  - `Lti_1p3.Tool.DeepLinking.Settings`
  - `Lti_1p3.Tool.DeepLinking.ContentItem`
  - `Lti_1p3.Tool.DeepLinking.ResponseBuilder`
  - `Lti_1p3.Tool.DeepLinking.CompatibilityPolicy`
  - `Lti_1p3.Tool.DeepLinking.Errors`
- Supervision tree impact:
  - No new long-lived processes.

## 4. Data Design
- Schema changes: none.
- Data lifecycle: request/settings/items/response structs are request-scoped.
- Migration/backfill strategy: additive APIs and notes for helper refactors.

## 5. Interfaces and Contracts
- `validate_request(launch_claims) -> {:ok, %DeepLinkingRequest{}} | {:error, error}`
- `content_item(type, attrs) -> {:ok, %ContentItem{}} | {:error, error}`
- `build_response(request, items, opts) -> {:ok, %{jwt: token, return_url: url}} | {:error, error}`

## 6. Runtime Behavior
- Stateless, concurrent-safe operations.
- No outbound HTTP in core validation/build path.
- Caller handles transport to deep-link return URL.

## 7. Security and Compliance
- Validate issuer/audience/message type from launch context.
- Enforce conditional `data` correlation rules.
- Redact sensitive values in logs and telemetry metadata.

## 8. Observability and Operations
- Metrics:
  - `tool_deep_linking.request.valid_count`
  - `tool_deep_linking.response.build_count`
  - `tool_deep_linking.error.count`
- Logs: issuer/client_id, item count, reason on failure.
- Tracing: telemetry spans around validation/build operations.

## 9. Testing Strategy
- Unit: claim validation, settings parsing, item subtype validation, error mapping.
- Integration: signed JWT claims and signature verification paths.
- End-to-end: deep-link request to response generation flow.
- Load/failure: large item list validation and signing behavior.

## 10. Open Questions
- Which tool deep-linking helpers should be extracted before platform phase 2 (claim correlation helpers, content item normalization, error mappers)?
