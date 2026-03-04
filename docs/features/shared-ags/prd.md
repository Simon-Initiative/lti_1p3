# Product Requirements Document

## 1. Feature Summary
- Name: Shared AGS Dependencies
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-04
- Status: Proposed

## 2. Problem Statement
- Tool and Platform AGS tracks require shared contracts to stay interoperable.
- Without explicit shared dependency ownership, error semantics, scope catalogs, and telemetry naming can drift.

### Current State Analysis
- `tool-ags` and `platform-ags` now exist as separate tracks.
- Shared dependency items are present implicitly but not managed as a dedicated feature.

## 3. Goals and Non-Goals
### Goals
- Define shared AGS reason atom/error map conventions used across tool and platform flows.
- Define shared operation/scope catalog and stable constants.
- Define shared telemetry naming and metadata conventions.
- Define shared compatibility policy interface for LMS/vendor quirks.
- Define shared documentation alignment requirements and migration guidance.

### Non-Goals
- Implementing role-specific AGS operation behavior.
- Building persistence adapters or endpoint handlers.

## 4. Users and Primary Use Cases
- Personas: Maintainers implementing tool/platform AGS modules.
- Core scenarios:
  - Tool and platform teams implement against one shared AGS reason/scope/telemetry contract.
  - Documentation stays consistent for equivalent AGS concepts.

## 5. Functional Requirements
1. Publish shared AGS reason atom catalog and error shape contract.
2. Publish shared AGS scope URLs and operation mapping contract.
3. Publish shared telemetry event and metadata contract.
4. Publish shared compatibility policy behavior contract.
5. Define versioning and migration rules for shared AGS contracts.
6. Add contract tests that can be reused by tool/platform implementations.
7. Document shared AGS dependency contracts in ExDoc and `docs/`.

## 6. Non-Functional Requirements
- Stability: shared contracts must be backward-compatible by default.
- Security: scope constants and auth semantics must be explicit and auditable.
- Operability: telemetry contract supports cross-role dashboarding.
- Documentation: shared contracts are clear and discoverable.

## 7. Success Metrics
- Tool and platform AGS implementations reference one shared reason/scope catalog.
- Contract test suite passes in both role-specific tracks.
- No role-specific divergence in documented AGS terminology.

## 8. Dependencies and Constraints
- Internal dependencies: `tool-ags` and `platform-ags` feature tracks.
- Constraints: shared module must remain role-agnostic and framework-agnostic.

## 9. Risks and Mitigations
- Risk: role teams need different semantics.
- Mitigation: keep shared contract minimal and extensible with explicit role overlays.
- Risk: over-centralization slows delivery.
- Mitigation: split mandatory core contract from optional compatibility policies.

## 10. Acceptance Criteria
1. Shared AGS reason/scope/telemetry contracts are published and approved.
2. Tool and platform AGS plans reference and consume shared contracts.
3. Shared contract tests exist and pass in CI.
4. Shared AGS docs include migration guidance for contract changes.
