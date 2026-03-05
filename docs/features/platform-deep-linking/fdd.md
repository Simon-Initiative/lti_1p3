# Functional Design Document

## 1. Design Overview
- Scope covered: Platform deep-link request building, response validation, content item parsing, observability.
- Assumptions:
  - Platform launch/session context includes expected correlation values.
  - Tool deep-linking implementation can provide extracted reusable helper modules.

## 2. System Context and Boundaries
- In-scope components:
  - `Lti_1p3.Platform.DeepLinking.RequestBuilder`
  - `Lti_1p3.Platform.DeepLinking.ResponseValidator`
  - `Lti_1p3.Platform.DeepLinking.ContentItemParser`
  - `Lti_1p3.Platform.DeepLinking.Errors`
  - Adoption of extracted reusable helper modules where duplication exists.
- Out-of-scope components:
  - Tool response generation behavior.
  - Host app persistence/UI workflows.

## 3. Architecture
- High-level flow:
  - Build request claims/context -> receive response JWT -> verify signature and claims -> validate correlation -> parse items -> return normalized response.
- Context/module responsibilities:
  - `Lti_1p3.Platform.DeepLinking.RequestBuilder`
  - `Lti_1p3.Platform.DeepLinking.ResponseValidator`
  - `Lti_1p3.Platform.DeepLinking.ContentItemParser`
  - `Lti_1p3.Platform.DeepLinking.CompatibilityPolicy`
  - `Lti_1p3.Platform.DeepLinking.Errors`
  - Reused helpers extracted from tool implementation (for example: claim correlation and content item normalization helpers).
- Supervision tree impact:
  - No new long-lived processes.

## 4. Data Design
- Schema changes: none.
- Data lifecycle: request/response/item structs are request-scoped unless host app persists.
- Migration/backfill strategy: additive API and helper extraction changes with migration notes.

## 5. Interfaces and Contracts
- `build_request(context, opts) -> {:ok, %DeepLinkingPlatformRequest{}} | {:error, error}`
- `validate_response(jwt, expected) -> {:ok, %DeepLinkingPlatformResponse{}} | {:error, error}`
- `parse_content_items(claims, opts) -> {:ok, [%ContentItem{}]} | {:error, error}`

## 6. Runtime Behavior
- Stateless validation/build operations.
- Concurrent-safe for many simultaneous launches.
- No long-lived processes or retries in core flow.

## 7. Security and Compliance
- Strict signature verification and issuer/audience checks.
- Enforce nonce/state/data correlation rules.
- Redact sensitive values from logs and telemetry metadata.

## 8. Observability and Operations
- Metrics:
  - `platform_deep_linking.request.build_count`
  - `platform_deep_linking.response.valid_count`
  - `platform_deep_linking.response.invalid_count`
- Logs: issuer/client_id, correlation result, item count, reason.
- Tracing: telemetry spans around request build and response validation.

## 9. Testing Strategy
- Unit: claim validation, correlation checks, item normalization, error mapping.
- Integration: signed response token validation paths.
- End-to-end: request creation through response consumption.
- Load/failure: high-volume response validation and malformed payload handling.

## 10. Open Questions
- Which extracted tool deep-linking helpers should be adopted before platform phase 2 to maximize reuse with minimal churn?
