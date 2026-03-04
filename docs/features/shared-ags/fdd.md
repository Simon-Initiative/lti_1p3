# Functional Design Document

## 1. Design Overview
- Scope covered: Shared AGS contract artifacts consumed by both tool and platform tracks.
- Assumptions:
  - Role-specific AGS modules are implemented independently.
  - Shared contracts are additive and versioned.

## 2. System Context and Boundaries
- In-scope components:
  - Shared AGS reason atom and error map definitions.
  - Shared AGS scope/operation mapping constants.
  - Shared AGS telemetry naming and metadata contract.
  - Shared compatibility policy behavior.
  - Shared contract test helpers.
- Out-of-scope components:
  - Tool AGS request/response handling.
  - Platform AGS endpoint orchestration and storage adapters.

## 3. Architecture
- High-level flow:
  - Define shared contracts -> role modules import/consume -> contract tests enforce compliance.
- Module responsibilities:
  - `Lti_1p3.Shared.AGS.Errors`
  - `Lti_1p3.Shared.AGS.ScopeCatalog`
  - `Lti_1p3.Shared.AGS.Telemetry`
  - `Lti_1p3.Shared.AGS.CompatibilityPolicy`
  - `Lti_1p3.Shared.AGS.ContractTest`

## 4. Data Design
- Schema changes: none.
- Data lifecycle: static constants and pure normalization helpers.
- Migration strategy: semantic versioning for shared contract changes with migration notes.

## 5. Interfaces and Contracts
- `error(reason, attrs) -> %{reason:, operation:, http_status:, retryable:, msg:}`
- `required_scope(operation) -> {:ok, scope_url} | {:error, :unknown_operation}`
- `telemetry_event(operation, outcome) -> event_name`
- `compatibility_profile(vendor) -> map()`

## 6. Runtime Behavior
- Pure functions; no process lifecycle impact.
- Deterministic contract resolution for all shared constants.

## 7. Security and Compliance
- Scope constants centrally controlled and reviewed.
- Error contract prevents token/PII leakage in shared formatter helpers.

## 8. Observability and Operations
- Standardized telemetry names and metadata keys.
- Shared docs for dashboard and alert mapping across tool/platform services.

## 9. Testing Strategy
- Unit: reason/scope/telemetry contract functions.
- Contract: reusable assertions for tool/platform conformance.
- Integration: verify both role tracks consume shared constants/events.

## 10. Documentation Strategy
- ExDoc for shared AGS modules.
- `docs/` reference for shared AGS contracts and migration guidance.
- Contract changes require changelog entry.

## 11. Decisions
1. Shared contract strictness:
Decision: strict for reason/scope names; extensible metadata fields.
Implementation impact: stable matching keys with role-specific extension room.

2. Compatibility policy scope:
Decision: shared default policy + optional role-specific adapters.
Implementation impact: core profile definitions stay centralized while allowing local overrides.
