# Product Requirements Document

## 1. Feature Summary
- Name: Shared Deep Linking Dependencies
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-04
- Status: Proposed

## 2. Problem Statement
- Tool and platform deep-linking tracks require one shared contract for correlation semantics, content item terminology, errors, and telemetry.
- Without a shared feature, role-specific implementations can drift and break interoperability.

### Current State Analysis
- `tool-deep-linking` and `platform-deep-linking` are now independent tracks.
- Shared dependency ownership has not been isolated into a dedicated feature package.

## 3. Goals and Non-Goals
### Goals
- Define shared correlation contract (`state`, `nonce`, conditional `data`).
- Define shared content item subtype terminology and normalization rules.
- Define shared error reason catalog and telemetry naming.
- Define shared compatibility policy semantics for subtype variance.
- Define versioning and migration rules for shared deep-linking contracts.

### Non-Goals
- Tool response JWT generation details.
- Platform request-launch and ingestion orchestration details.

## 4. Users and Primary Use Cases
- Personas: Maintainers working on tool/platform deep-linking modules.
- Core scenarios:
  - Both tracks implement against one correlation and content-item contract.
  - Interop failures are diagnosable through shared reason/telemetry semantics.

## 5. Functional Requirements
1. Publish shared correlation validation contract.
2. Publish shared content item terminology and parsing contract.
3. Publish shared reason atom/error map contract.
4. Publish shared telemetry event/metadata contract.
5. Publish shared compatibility policy contract for unsupported subtypes.
6. Provide reusable contract tests for tool/platform conformance.
7. Document shared deep-linking contracts and migration guidance.

## 6. Non-Functional Requirements
- Stability: correlation and reason atom semantics remain backward compatible.
- Security: shared validation contract preserves strict JWT/correlation posture.
- Operability: telemetry contract supports cross-role diagnostics.
- Documentation: contracts remain concise and implementation-ready.

## 7. Success Metrics
- Tool/platform deep-linking tracks pass shared contract tests.
- No drift in `data` correlation behavior or reason atom names.
- Shared docs are referenced by both role-specific guides.

## 8. Dependencies and Constraints
- Internal dependencies: role tracks for tool/platform deep linking.
- Constraints: shared layer must remain role-agnostic and minimal.

## 9. Risks and Mitigations
- Risk: shared contract becomes too broad.
- Mitigation: constrain shared scope to interop-critical semantics only.
- Risk: strict correlation rules block legitimate edge behavior.
- Mitigation: compatibility policy with explicit strict/tolerant modes.

## 10. Acceptance Criteria
1. Shared correlation/content-item/error/telemetry contracts are published.
2. Tool and platform tracks consume shared contracts.
3. Shared contract tests enforce conformance in CI.
4. Migration guidance is published for previous behavior.
