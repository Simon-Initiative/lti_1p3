# Functional Design Document

## 1. Design Overview

- Scope covered: Deep linking request validation, response JWT construction, content item modeling, and platform response validation helpers.
- Assumptions:
  - Core launch validation has message-type dispatch extensibility.
  - Unified error and telemetry conventions are available.

## 2. System Context and Boundaries

- In-scope components:
  - Deep linking message validator modules.
  - Deep linking request and response domain structs.
  - Response JWT builder/signing and validation helpers.
- Out-of-scope components:
  - Tool content selection UI workflows.
  - Platform post-processing UI logic.

## 3. Architecture

- High-level flow:
  - Tool receives launch -> message dispatcher selects deep-linking validator -> request normalized.
  - Tool selects items -> response builder signs JWT -> POSTs to `deep_link_return_url` via host app.
  - Platform validates response JWT -> parses items and correlation data.
- Context/module responsibilities:
  - `Lti_1p3.DeepLinking.RequestValidator`: claim-level deep linking request checks.
  - `Lti_1p3.DeepLinking.ContentItem`: typed item builders and validators.
  - `Lti_1p3.DeepLinking.ResponseBuilder`: JWT claim assembly/signing.
  - `Lti_1p3.DeepLinking.ResponseValidator`: platform-side response verification.
- Supervision tree impact:
  - No new long-lived processes.

## 4. Data Design

- Schema changes:
  - None required by library.
- Data lifecycle:
  - Deep linking request/response payloads are ephemeral unless caller persists them.
- Migration/backfill strategy:
  - Introduce new structs and helper functions without persistence migration.

## 5. Interfaces and Contracts

- Internal APIs:
  - `validate_request(launch_claims) -> {:ok, %DeepLinkingRequest{}} | {:error, error}`
  - `build_response(request, items, opts) -> {:ok, %{jwt: token, return_url: url}} | {:error, error}`
  - `validate_response(jwt, expected) -> {:ok, %DeepLinkingResponse{}} | {:error, error}`
  - `content_item(type, attrs) -> {:ok, %ContentItem{}} | {:error, error}`
- External APIs/webhooks:
  - Caller app handles HTTP form post to `deep_link_return_url`.
- Event/message formats:
  - Response claims include message type, version, content_items, and data.

## 6. Runtime Behavior

- Process model:
  - Stateless validation/building functions.
- Concurrency model:
  - Safe concurrent deep-link request handling.
- Failure handling/retries:
  - Build/validate operations do not retry; caller handles transport retries.
- Timeouts/circuit breakers:
  - No outbound HTTP in core module path.

## 7. Security and Compliance

- AuthN/AuthZ impact:
  - Strict JWT signature and issuer/audience checks in response validation.
- Data protection:
  - Redact content URLs and user identifiers in logs when configured.
- Audit/logging requirements:
  - Log request validation result, response claim count, and validation failures by reason.

## 8. Observability and Operations

- Metrics:
  - `deep_linking.request.valid_count`, `deep_linking.response.build_count`, `deep_linking.response.invalid_count`.
- Logs:
  - Structured logs with request issuer/client_id and response item count.
- Tracing:
  - Telemetry spans for request validation and response build.
- Alerts/runbooks:
  - Alert on sustained deep linking validation failures.

## 9. Testing Strategy

- Unit:
  - Claim requirement checks, content item validation, response claim assembly.
- Integration:
  - Tool request validation and platform response validation with signed JWTs.
- Contract:
  - Message type dispatch includes deep linking request path.
- End-to-end:
  - Simulated deep linking handshake from request to response consumption.
- Load/failure:
  - Large content item lists and malformed item payload fuzzing.

## 10. Documentation Strategy

- ExDoc requirements:
  - Document all public deep-linking modules/functions with `@moduledoc`, `@doc`, and `@spec`.
  - Add examples for request validation, content item construction, and response token generation.
- Supporting docs:
  - Maintain deep-linking request/response integration and troubleshooting guides under `docs/`.
- Verification:
  - `mix docs` generation and docs completeness checks are required for merge.

## 11. Decisions

1. Content item subtype defaults and flags:
Decision:
- Default enabled: `ltiResourceLink`, `link`
- Feature-flagged: `file`, `html`, `image`
- Always feature-flagged: extended/custom/new types via spec extension mechanisms
Implementation impact: deep-linking content item validation/building must enforce this enablement policy with explicit errors when disabled types are requested.

2. Response validator `data` behavior:
Decision: allow nil `data` in response when request `data` is absent, and log a warning for potential integration issues.
Implementation impact: response validation should not fail solely for missing `data` when request omitted it, but should emit structured warning logs/telemetry for operator visibility.
