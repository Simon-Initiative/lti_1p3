# Product Requirements Document

## 1. Feature Summary
- Name: LTI Deep Linking 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-03
- Status: Proposed

## 2. Problem Statement
- Current pain: Deep Linking claims exist but full request/response flow and content-item response handling are not complete.
- Why now: Deep Linking is required for full LTI service completeness and certification readiness.

### Current State Analysis
- `Lti_1p3.Claims.DeepLinkingSettings` exists, but launch validation currently only validates resource link message type.
- No complete tool-side deep linking request validator is present in message validator dispatch.
- No first-class API exists to build/sign deep linking response JWTs with content items.
- No platform-side helper exists to validate/consume deep linking responses.
- Current tests do not provide deep linking request/response end-to-end coverage.

## 3. Goals and Non-Goals
### Goals
- Implement complete deep linking request validation for tool launches.
- Implement deep linking response builder with content item modeling and JWT signing.
- Provide platform-side deep linking response validation/consumption helpers.
- Align deep linking API with unified library functional conventions.
- Make deep-linking documentation complete in ExDoc and dedicated guides under `docs/`.

### Non-Goals
- Building authoring UIs for selecting deep link content.
- Persisting content-item catalogs in the library.

## 4. Users and Primary Use Cases
- Personas: Tool developers offering content selection; platform developers consuming deep linking responses.
- Core scenarios:
  - Tool validates incoming `LtiDeepLinkingRequest` and reads deep linking settings.
  - Tool builds a signed `LtiDeepLinkingResponse` with selected content items.
  - Platform validates deep linking response JWT and extracts content items/data correlation.

## 5. Functional Requirements
1. Add message validator for `LtiDeepLinkingRequest` with required claim checks.
2. Parse deep linking settings claim into typed struct with defaults and validation.
3. Define typed content item models (link, ltiResourceLink, html, image, file where applicable).
4. Implement response JWT builder with message type/version/content_items/data claims.
5. Support optional AGS and custom claim embedding in deep linking items where valid.
6. Implement platform-side deep linking response validation helpers.
7. Enforce nonce/state/data correlation and issuer/audience validation for responses.
8. Provide clear errors for unsupported content-item types and invalid payloads.
9. Document all deep-linking public modules/functions with `@moduledoc`, `@doc`, and `@spec`.
10. Add/update deep-linking guides under `docs/` (request handling, response building, platform validation, interoperability notes).

## 6. Non-Functional Requirements
- Reliability: Response builder must produce deterministic payloads for same inputs.
- Performance: Deep linking response build/validation should be CPU-bound and complete < 20ms local.
- Security/Compliance: JWT validation and signing must follow same strict core checks.
- Observability: Emit telemetry for request validation, response build, and response validation outcomes.
- Documentation: 100% deep-linking public API ExDoc coverage and complete supporting guides in `docs/`.

## 7. Success Metrics
- Product metrics:
  - Pass deep linking conformance scenarios in certification tests.
  - Successful deep linking exchange with at least 2 LMS sandboxes.
- Technical metrics:
  - >= 90% deep linking module coverage.
  - 100% required claim validation cases covered.

## 8. Dependencies and Constraints
- Internal dependencies: Core launch/message validation refactor; claims system; key signing utilities.
- External dependencies: LMS behavior around accepted content item types.
- Constraints: Keep framework-agnostic and avoid UI assumptions.

## 9. Risks and Mitigations
- Risk: LMS-specific limitations on content item types break interoperability.
- Mitigation: Provide capability negotiation and configurable fallback item shaping.
- Risk: Data correlation mismatches across request/response.
- Mitigation: Enforce explicit `data` passthrough tests and validation constraints.

## 10. Acceptance Criteria
1. Given an incoming deep linking launch, when validated, then it returns typed deep linking request data including settings claim.
2. Given selected content items, when response builder is called, then it returns signed JWT with valid deep linking response claims.
3. Given malformed content items or missing required claims, when building/validating, then structured errors are returned.
4. Given platform receives deep linking response, when validated, then content items are extracted with correlation `data` preserved.
5. Given unsupported item type for target LMS, when compatibility policy is enabled, then fallback or explicit error behavior is deterministic.
6. Given `mix docs` runs, when deep-linking docs are generated, then all deep-linking public APIs and supporting guides are complete and current.
