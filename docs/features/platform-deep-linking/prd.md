# Product Requirements Document

## 1. Feature Summary
- Name: Platform Deep Linking 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-04
- Status: Proposed

## 2. Problem Statement
- Current pain: Platform-side deep linking behavior is not captured as a dedicated feature set.
- Why now: Platforms must issue deep-linking requests and validate returned content items for complete interoperability.

### Current State Analysis
- Existing planning emphasizes tool request validation/response build.
- Platform request generation and response verification contracts are not isolated.
- No dedicated provider contract guidance for consuming returned content items.

## 3. Goals and Non-Goals
### Goals
- Implement platform APIs to initiate deep-linking requests and validate responses.
- Enforce nonce/state/data correlation, issuer/audience checks, and signature validation.
- Normalize extracted content items into typed structures for host apps.
- Provide extensible compatibility handling for item subtype and claim variation.
- Document platform deep-linking setup and consumption patterns.

### Non-Goals
- Building platform authoring UX.
- Persisting deep-linking selections by default.

## 4. Users and Primary Use Cases
- Personas: Platform developers launching deep-linking flows and consuming returned items.
- Core scenarios:
  - Generate deep-linking launch claims and redirects.
  - Validate tool deep-linking response JWT.
  - Extract content items and correlation data for host app processing.

## 5. Functional Requirements
1. Provide helper API for platform deep-linking request claim construction.
2. Validate deep-linking response JWT signatures and expected claims.
3. Enforce issuer/audience/nonce/state/data correlation checks.
4. Parse and normalize returned content items into typed structures.
5. Return structured errors for signature, claim, and correlation failures.
6. Provide compatibility options for subtype or claim variance.
7. Emit telemetry/logging for request and response processing outcomes.
8. Document all public platform deep-linking APIs and guides.

## 6. Non-Functional Requirements
- Reliability: deterministic validation outcomes for identical inputs.
- Performance: response validation stays CPU-bound with bounded parsing costs.
- Security/Compliance: strict JWT verification and correlation checks.
- Documentation: complete ExDoc and integration guides.

## 7. Success Metrics
- Platform deep-linking conformance scenarios pass certification matrix.
- Interoperability verified with at least 2 reference tools.
- >= 90% coverage for platform deep-linking modules.

## 8. Dependencies and Constraints
- Internal: platform launch pipeline, key retrieval, JWT verification.
- External: tool behavior variance in optional deep-linking claims.
- Constraints: framework-agnostic public APIs.

## 9. Risks and Mitigations
- Risk: correlation mismatches create false rejects.
- Mitigation: explicit expected-input contract and exhaustive tests.
- Risk: subtype variations across tools.
- Mitigation: compatibility profiles with explicit policy behavior.

## 10. Acceptance Criteria
1. Given platform deep-linking initiation input, helper APIs produce valid request claims/context.
2. Given valid tool response JWT, validator returns typed response and content items.
3. Given invalid signature/claims/correlation, validator returns structured errors.
4. Given compatibility policy settings, subtype variance handling is deterministic.
5. Given `mix docs`, platform deep-linking docs are complete and current.
