# Product Requirements Document

## 1. Feature Summary
- Name: Platform AGS 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-04
- Status: Proposed

## 2. Problem Statement
- Current pain: Platform-side AGS behavior is not defined as a first-class feature set.
- Why now: Certification and production interoperability require explicit platform AGS contracts for authorization, line item, score, and result service behavior.

### Current State Analysis
- Existing planning primarily targets tool-side AGS client workflows.
- Platform launch flows expose AGS claims but lack dedicated AGS service APIs and error semantics.
- No explicit conformance matrix exists for platform AGS endpoint behavior.

## 3. Goals and Non-Goals
### Goals
- Implement platform-side AGS service surface for line items, scores, and results.
- Validate launch and token scopes against AGS capabilities.
- Provide behavior contracts for AGS persistence adapters.
- Normalize platform AGS errors, telemetry, and docs.
- Maintain compatibility with framework-agnostic Plug/Phoenix host apps.

### Non-Goals
- Implementing a full LMS gradebook product.
- Enforcing institution-specific grading business rules.

## 4. Users and Primary Use Cases
- Personas: Platform integrators exposing AGS to tools.
- Core scenarios:
  - Platform authorizes tool tokens for AGS scopes.
  - Platform serves line item CRUD endpoints.
  - Platform accepts scores and returns results for authorized contexts.

## 5. Functional Requirements
1. Define AGS platform domain models for line item, score event, and result view.
2. Define behavior contracts for AGS storage and lookup.
3. Implement scope authorization policy for lineitem/scores/result operations.
4. Implement endpoint handlers/helpers for line items, scores, and results.
5. Enforce deployment/context linkage and authorization checks.
6. Return structured errors with stable reason atoms and HTTP mapping guidance.
7. Emit telemetry/logs for operation outcomes and denials.
8. Provide compatibility hooks for LMS/tool interoperability edge cases.
9. Document all platform AGS public modules/functions.
10. Add platform AGS implementation guide under `docs/`.

## 6. Non-Functional Requirements
- Reliability: consistent endpoint behavior under concurrent tool requests.
- Performance: predictable pagination and bounded query costs.
- Security/Compliance: strict scope/context enforcement and audit logging.
- Documentation: full public API coverage and operational guidance.

## 7. Success Metrics
- Platform AGS conformance scenarios pass certification matrix.
- Successful interop with at least 2 reference tools.
- >= 90% platform AGS module coverage.

## 8. Dependencies and Constraints
- Internal: platform launch/token modules, provider contracts, role/deployment validation.
- External: host application persistence adapter quality.
- Constraints: preserve framework-agnostic and pluggable architecture.

## 9. Risks and Mitigations
- Risk: ambiguous storage contract leads to inconsistent behavior.
- Mitigation: define strict behavior contract and contract tests.
- Risk: scope enforcement gaps create security issues.
- Mitigation: centralized scope policy and exhaustive authorization tests.

## 10. Acceptance Criteria
1. Given authorized AGS scopes, platform line item/score/result operations succeed with spec-compliant responses.
2. Given insufficient scope or mismatched deployment/context, platform returns explicit authorization errors.
3. Given provider contract implementation, platform endpoints operate without framework lock-in.
4. Given failures, platform returns normalized error reasons and telemetry metadata.
5. Given `mix docs`, platform AGS docs and guides are complete and current.
