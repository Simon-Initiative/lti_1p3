# Product Requirements Document

## 1. Feature Summary
- Name: Platform NRPS 2.0 Complete Support
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-05
- Status: Proposed

## 2. Problem Statement
- Current pain: Platform-side NRPS service behavior requires complete implementation guidance for authorization, pagination, and filter handling.
- Why now: Certification and production tool interoperability require robust roster endpoint behavior.

### Current State Analysis
- Platform NRPS operations are not fully implemented.
- Authorization and filter semantics need complete coverage.
- Tool NRPS will be implemented first and should drive reusable module extraction where duplication appears.

## 3. Goals and Non-Goals
### Goals
- Implement platform NRPS membership listing behavior with scope/context checks.
- Support pagination and configured filters with deterministic semantics.
- Return structured errors and telemetry metadata.
- Reuse modules extracted from tool NRPS when equivalent logic already exists.
- Publish complete platform NRPS documentation.

### Non-Goals
- Built-in SIS synchronization.
- Institution-specific role mapping policy defaults.

## 4. Users and Primary Use Cases
- Personas: Platform developers exposing roster services to tools.
- Core scenarios:
  - Authorize `contextmembership.readonly` access.
  - Serve memberships with page and filter controls.
  - Return explicit denials for unauthorized requests.

## 5. Functional Requirements
1. Implement platform NRPS membership and page models.
2. Enforce scope/deployment/context checks before retrieval.
3. Support pagination metadata and link generation.
4. Support configured role/status/resource-link filters.
5. Return structured errors with stable reason atoms and HTTP mapping.
6. Emit telemetry/logs for request, result size, denials, and failures.
7. Extract duplicated helpers from tool NRPS into reusable modules and consume them in platform NRPS.
8. Document platform NRPS APIs and integration guidance.

## 6. Non-Functional Requirements
- Reliability: deterministic page boundaries and repeatable results.
- Performance: bounded page size and query behavior.
- Security/Compliance: strict authorization checks and PII-aware logging.
- Documentation: complete ExDoc and integration guides.

## 7. Success Metrics
- Platform NRPS conformance scenarios pass certification matrix.
- Interoperability verified with at least 2 reference tools.
- >= 90% coverage for platform NRPS modules.
- Cross-role duplicate logic is reduced through extracted reusable modules.

## 8. Dependencies and Constraints
- Internal dependencies: platform token/scope validation, tool NRPS extracted reusable helpers.
- External dependencies: host application membership data source behavior.
- Constraints: framework-agnostic APIs and stable tagged-tuple return shapes.

## 9. Risks and Mitigations
- Risk: duplicate pagination/filter logic drifts between roles.
- Mitigation: extract shared utility modules from tool implementation before finalizing platform operations.
- Risk: filter semantics mismatch across environments.
- Mitigation: explicit supported filter configuration and deterministic errors.

## 10. Acceptance Criteria
1. Given authorized scope/context, platform returns paginated memberships.
2. Given unsupported or unauthorized requests, platform returns explicit structured errors.
3. Given duplicate logic already solved in tool NRPS, platform consumes extracted reusable modules.
4. Given telemetry instrumentation, request/result/denial metrics are emitted.
5. Given docs generation, platform NRPS API and guide docs are complete.
