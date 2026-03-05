# Product Requirements Document

## 1. Feature Summary
- Name: Platform AGS 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-05
- Status: Proposed

## 2. Problem Statement
- Current pain: Platform-side AGS service behavior needs a complete, spec-aligned implementation plan.
- Why now: Certification and production interoperability require robust platform AGS authorization and operations.

### Current State Analysis
- Platform AGS endpoint behavior is not fully implemented.
- Authorization and response semantics need complete test coverage.
- Tool AGS implementation will land first and should inform shared utility extraction.

## 3. Goals and Non-Goals
### Goals
- Implement platform AGS service behavior for line items, scores, and results.
- Enforce deployment/context/scope authorization with stable reason atoms.
- Provide typed models and normalized error/HTTP mapping guidance.
- Reuse extracted modules for duplicated logic that already exists in tool AGS implementation.
- Publish complete platform AGS documentation.

### Non-Goals
- Building a full LMS gradebook product.
- Institution-specific grading policies.

## 4. Users and Primary Use Cases
- Personas: Platform developers exposing AGS endpoints to tools.
- Core scenarios:
  - Authorize AGS operations from tool access tokens.
  - Serve line item CRUD responses.
  - Accept scores and return results.

## 5. Functional Requirements
1. Implement platform AGS domain models for line item, score event, and result view.
2. Implement authorization policy for scope, deployment, and context checks.
3. Implement service operations for line items, scores, and results.
4. Return structured errors with reason atoms and HTTP mapping.
5. Emit telemetry/logging for operation outcomes and denials.
6. During implementation, extract duplicated helper logic from tool AGS modules into reusable modules and consume them in platform AGS.
7. Document all public platform AGS APIs and integration guidance.

## 6. Non-Functional Requirements
- Reliability: deterministic behavior under concurrent requests.
- Performance: bounded pagination and query cost.
- Security/Compliance: strict authorization checks and audit-friendly logs.
- Documentation: complete ExDoc and implementation guides.

## 7. Success Metrics
- Platform AGS conformance scenarios pass certification matrix.
- Interop validated with at least 2 reference tools.
- >= 90% coverage for platform AGS modules.
- Duplicated cross-role logic is reduced through reusable extracted modules.

## 8. Dependencies and Constraints
- Internal dependencies: platform launch/token modules, tool AGS extracted reusable helpers.
- External dependencies: host application persistence integration quality.
- Constraints: framework-agnostic APIs and stable return tuple shapes.

## 9. Risks and Mitigations
- Risk: duplicated utility logic diverges between roles.
- Mitigation: extract reusable modules from tool implementation before parallel platform rewrites.
- Risk: authorization gaps create security issues.
- Mitigation: centralized policy helpers and exhaustive denial-path tests.

## 10. Acceptance Criteria
1. Given authorized AGS scopes/context, platform operations succeed with spec-compliant payloads.
2. Given insufficient scope or context mismatch, platform returns explicit authorization errors.
3. Given duplicated helper logic already solved in tool AGS, platform uses extracted reusable modules.
4. Given failures, platform returns normalized reasons and telemetry metadata.
5. Given docs generation, platform AGS API and guide docs are complete.
