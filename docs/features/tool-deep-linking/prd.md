# Product Requirements Document

## 1. Feature Summary
- Name: Tool Deep Linking 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-04
- Status: Proposed

## 2. Problem Statement
- Current pain: Tool deep linking support is incomplete for request validation and response generation.
- Why now: Deep linking is required for tool-side interoperability and certification.

### Current State Analysis
- Deep linking settings claim exists but request validation is not complete in dispatch pipeline.
- No first-class response builder for signed `LtiDeepLinkingResponse` JWTs.
- Content item modeling is incomplete and inconsistently validated.

## 3. Goals and Non-Goals
### Goals
- Validate `LtiDeepLinkingRequest` launches with typed settings structs.
- Build/sign deep linking response JWTs with validated content items.
- Enforce deterministic error semantics for invalid requests/items.
- Add telemetry and compatibility controls for LMS item support variance.
- Publish complete tool deep-linking docs and examples.

### Non-Goals
- Tool content selection UI.
- Platform response consumption workflows.

## 4. Users and Primary Use Cases
- Personas: Tool developers returning content selections to platforms.
- Core scenarios:
  - Validate deep linking launch claims.
  - Build content items.
  - Sign deep linking response and submit to return URL in host app.

## 5. Functional Requirements
1. Add message validator for `LtiDeepLinkingRequest`.
2. Parse settings claim into typed struct with defaults/validation.
3. Implement typed content items with subtype validation.
4. Implement response claim builder and JWT signing helper.
5. Preserve and validate request `data` correlation rules.
6. Return structured reasoned errors for invalid claims/items.
7. Support feature-flagged content item subtype enablement.
8. Emit telemetry for request validation and response build outcomes.
9. Document public tool deep-linking APIs.
10. Add/update tool deep-linking guides under `docs/`.

## 6. Non-Functional Requirements
- Reliability: deterministic response payload generation for equal inputs.
- Performance: local validation/build under 20ms for standard payload sizes.
- Security/Compliance: strict claim validation and signing key handling.
- Documentation: full ExDoc and integration guides.

## 7. Success Metrics
- Tool deep linking conformance scenarios pass certification matrix.
- Successful interoperability with at least 2 LMS sandboxes.
- >= 90% coverage for tool deep-linking modules.

## 8. Dependencies and Constraints
- Internal: launch/message validation pipeline, signing utilities, claims modules.
- External: LMS content-item subtype acceptance differences.
- Constraints: framework-agnostic and UI-independent.

## 9. Risks and Mitigations
- Risk: platform-specific subtype restrictions.
- Mitigation: compatibility policy with deterministic fallback/error behavior.
- Risk: request/response data mismatch.
- Mitigation: explicit data passthrough validation tests.

## 10. Acceptance Criteria
1. Given deep linking launch claims, request validation returns typed request/settings structs.
2. Given valid items, response builder returns signed JWT with required claims.
3. Given malformed items/claims, APIs return structured reasoned errors.
4. Given subtype restrictions, compatibility policy yields deterministic fallback or explicit failure.
5. Given `mix docs`, tool deep-linking docs are complete and current.
