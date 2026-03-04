# Functional Design Document

## 1. Design Overview
- Scope covered: Platform deep-link request construction, response JWT validation, item normalization, observability.
- Assumptions:
  - Platform launch/session context carries expected nonce/state/data values.
  - Shared JWT verification utilities are available.

## 2. System Context and Boundaries
- In-scope components:
  - Platform deep-link request helper APIs.
  - Response validator and claim/correlation checks.
  - Typed response/content item normalization.
- Out-of-scope components:
  - Tool-side deep-link response generation.
  - Host app persistence/UI workflows.

## 3. Architecture
- High-level flow:
  - Build request context -> send launch via host app -> receive response JWT -> verify signature/claims -> parse items -> return normalized struct.
- Module responsibilities:
  - `Lti_1p3.Platform.DeepLinking.RequestBuilder`
  - `Lti_1p3.Platform.DeepLinking.ResponseValidator`
  - `Lti_1p3.Platform.DeepLinking.ContentItemParser`
  - `Lti_1p3.Platform.DeepLinking.CompatibilityPolicy`

## 4. Data Design
- Schema changes: none.
- Data lifecycle: deep-link request/response data is caller-managed unless persisted by host app.
- Migration strategy: additive APIs with migration notes for existing helper replacements.

## 5. Interfaces and Contracts
- `build_request(context, opts) -> {:ok, %DeepLinkingPlatformRequest{}} | {:error, error}`
- `validate_response(jwt, expected) -> {:ok, %DeepLinkingPlatformResponse{}} | {:error, error}`
- `parse_content_items(claims, opts) -> {:ok, [%ContentItem{}]} | {:error, error}`

## 6. Runtime Behavior
- Stateless helper and validator modules.
- No long-lived processes or retries in core validation flow.
- Safe for concurrent validation across many launches.

## 7. Security and Compliance
- Strict signature validation and issuer/audience checks.
- Correlation checks for `nonce`, `state`, and `data` where applicable.
- Structured audit logs for rejects with redacted sensitive fields.

## 8. Observability and Operations
- Metrics: `platform_deep_linking.request.build_count`, `platform_deep_linking.response.valid_count`, `platform_deep_linking.response.invalid_count`.
- Logs: issuer/client_id, correlation result, item count, reason on failure.
- Tracing: telemetry spans around build/validate operations.

## 9. Testing Strategy
- Unit: claim/correlation validation rules and content item normalization.
- Integration: signed response token verification paths.
- Contract: expected input validation for request/session correlation.
- End-to-end: platform request through tool response consumption.

## 10. Documentation Strategy
- ExDoc on all public platform deep-linking modules/functions.
- Guides for initiating deep-linking flows and validating responses.
- Merge gate includes docs generation and example checks.

## 11. Decisions
1. Correlation strictness:
Decision: enforce strict `state` and conditional `data` matching.
Implementation impact: response validation fails with explicit reasons on mismatch.

2. Unsupported content item handling:
Decision: configurable strict vs tolerant mode.
Implementation impact: strict mode fails fast; tolerant mode returns parsed supported subset with warnings.
