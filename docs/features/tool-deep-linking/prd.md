# Product Requirements Document

## 1. Feature Summary
- Name: Tool Deep Linking 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-05
- Status: Proposed

## 2. Problem Statement
- Current pain: Tool deep-linking support is incomplete for request validation and response generation.
- Why now: Deep linking interoperability and certification require complete tool behavior.

### Current State Analysis
- Request validation is not complete in dispatch.
- Response builder/signing support is incomplete.
- Content item validation and error semantics are inconsistent.

## 3. Goals and Non-Goals
### Goals
- Validate `LtiDeepLinkingRequest` launches with typed settings.
- Build and sign deep-linking response JWTs with validated content items.
- Preserve deterministic error reason semantics.
- Add telemetry and compatibility controls for LMS variance.
- Design utility extraction seams in tool implementation for later platform reuse.

### Non-Goals
- Tool UI for content selection.
- Platform response consumption behavior.

## 4. Users and Primary Use Cases
- Personas: Tool developers returning selected content items.
- Core scenarios:
  - Validate deep-linking launch claims.
  - Build content items.
  - Build/sign response JWT for return URL submission.

## 5. Functional Requirements
1. Implement validator for `LtiDeepLinkingRequest` claims.
2. Parse deep-linking settings into typed structs.
3. Implement content item builders and subtype validation.
4. Implement response claim builder and JWT signing helper integration.
5. Enforce conditional `data` correlation rules.
6. Return structured reasoned errors for validation/build failures.
7. Emit telemetry for request validation and response build outcomes.
8. Document public tool deep-linking APIs and guides.
9. Identify duplicated logic candidates and define extractable module boundaries for platform reuse.

## 6. Non-Functional Requirements
- Reliability: deterministic output for identical inputs.
- Performance: bounded local validation/build processing.
- Security/Compliance: strict claim checks and signing-key handling.
- Documentation: complete ExDoc and guide coverage.

## 7. Success Metrics
- Tool deep-linking conformance scenarios pass certification matrix.
- Interoperability verified with at least 2 LMS sandboxes.
- >= 90% coverage for tool deep-linking modules.
- Reusable utility candidates are documented and tested before platform deep-linking implementation starts.

## 8. Dependencies and Constraints
- Internal dependencies: launch validation, signing utilities, claims modules.
- External dependencies: LMS item subtype acceptance variance.
- Constraints: framework-agnostic API design and stable tagged-tuple shapes.

## 9. Risks and Mitigations
- Risk: platform-specific subtype restrictions.
- Mitigation: compatibility policy with deterministic fallback/error behavior.
- Risk: request/response data mismatch.
- Mitigation: explicit data correlation tests.

## 10. Acceptance Criteria
1. Given deep-linking launch claims, validation returns typed request/settings structs.
2. Given valid items, response builder returns signed JWT with required claims.
3. Given malformed items/claims, APIs return structured reasoned errors.
4. Given configured compatibility behavior, subtype variance handling is deterministic.
5. Given docs generation, tool deep-linking API and guide docs are complete.
