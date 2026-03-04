# Functional Design Document

## 1. Design Overview
- Scope covered: Tool deep-link request validation, content item modeling, response JWT build/sign.
- Assumptions:
  - Launch dispatch supports message-type extensibility.
  - Unified error and telemetry conventions are available.

## 2. System Context and Boundaries
- In-scope components:
  - Request validator and settings parser.
  - Content item builders/validators.
  - Response claim assembly and JWT signing.
- Out-of-scope components:
  - Platform-side response validation.
  - Tool UI workflows.

## 3. Architecture
- High-level flow:
  - Validate launch message type and required claims -> normalize request -> validate/build content items -> assemble/sign response JWT.
- Module responsibilities:
  - `Lti_1p3.Tool.DeepLinking.RequestValidator`
  - `Lti_1p3.Tool.DeepLinking.Settings`
  - `Lti_1p3.Tool.DeepLinking.ContentItem`
  - `Lti_1p3.Tool.DeepLinking.ResponseBuilder`
  - `Lti_1p3.Tool.DeepLinking.CompatibilityPolicy`

## 4. Data Design
- Schema changes: none.
- Data lifecycle: request/settings/items/response structs are ephemeral.
- Migration strategy: additive APIs with compatibility notes for renamed helpers.

## 5. Interfaces and Contracts
- `validate_request(launch_claims) -> {:ok, %DeepLinkingRequest{}} | {:error, error}`
- `content_item(type, attrs) -> {:ok, %ContentItem{}} | {:error, error}`
- `build_response(request, items, opts) -> {:ok, %{jwt: token, return_url: url}} | {:error, error}`

## 6. Runtime Behavior
- Stateless validation/build operations.
- No outbound HTTP in core flow.
- Caller app handles transport concerns for response posting.

## 7. Security and Compliance
- Enforce issuer/audience/message-type checks from validated launch context.
- Use configured active signing key only.
- Redact sensitive values from logs/telemetry.

## 8. Observability and Operations
- Metrics: `tool_deep_linking.request.valid_count`, `tool_deep_linking.response.build_count`, `tool_deep_linking.error.count`.
- Structured logs include issuer/client_id and item counts.
- Telemetry spans around validation and build operations.

## 9. Testing Strategy
- Unit: claim validation, item subtype rules, response claim assembly.
- Integration: signed JWT claim assertions.
- Contract: dispatch integration for deep linking message type.
- End-to-end: tool deep-link request to response generation flow.

## 10. Documentation Strategy
- ExDoc on all public tool deep-linking modules/functions.
- Guides for request validation, item construction, and response posting.
- Merge gate includes `mix docs` and docs example verification.

## 11. Decisions
1. Default subtype enablement:
Decision: enable `link` and `ltiResourceLink` by default; gate others behind config.
Implementation impact: explicit errors for disabled types.

2. Missing request data behavior:
Decision: allow nil response `data` only when request omits `data`.
Implementation impact: validation enforces conditional data correlation rules.
