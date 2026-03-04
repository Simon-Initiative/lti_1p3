# Functional Design Document

## 1. Design Overview
- Scope covered: shared NRPS contract definitions and conformance helpers.
- Assumptions:
  - Role tracks implement runtime logic independently.
  - Shared contract layer only owns cross-role semantics.

## 2. System Context and Boundaries
- In-scope components:
  - Scope constant catalog.
  - Filter capability and validation terminology.
  - Pagination metadata schema helpers.
  - Shared error and telemetry contracts.
  - Contract test helpers.
- Out-of-scope components:
  - Tool client pagination implementation.
  - Platform provider/endpoint orchestration.

## 3. Architecture
- High-level flow:
  - Shared contracts defined -> consumed in role tracks -> validated with shared tests.
- Module responsibilities:
  - `Lti_1p3.Shared.NRPS.ScopeCatalog`
  - `Lti_1p3.Shared.NRPS.FilterPolicy`
  - `Lti_1p3.Shared.NRPS.PaginationMetadata`
  - `Lti_1p3.Shared.NRPS.Errors`
  - `Lti_1p3.Shared.NRPS.Telemetry`
  - `Lti_1p3.Shared.NRPS.ContractTest`

## 4. Data Design
- Schema changes: none.
- Data lifecycle: constants and pure helper transformations.
- Migration strategy: versioned contract updates with migration notes.

## 5. Interfaces and Contracts
- `required_scope(:list_memberships) -> scope_url`
- `validate_filters(filters, capability) -> :ok | {:error, error}`
- `normalize_pagination(meta) -> {:ok, normalized} | {:error, error}`
- `error(reason, attrs) -> %{reason:, operation:, msg:, details: map()}`
- `telemetry_event(operation, outcome) -> event_name`

## 6. Runtime Behavior
- Pure shared modules with deterministic output.
- No supervision/runtime lifecycle changes.

## 7. Security and Compliance
- Scope definitions centralized and reviewed.
- Shared error helpers redact PII-sensitive fields by default.

## 8. Observability and Operations
- Shared telemetry naming and metadata keys across role tracks.
- Shared operational docs for dashboards and alert thresholds.

## 9. Testing Strategy
- Unit: scope/filter/pagination/error helpers.
- Contract: reusable tests for tool/platform conformance.
- Integration: verify role tracks emit shared telemetry naming and reasons.

## 10. Documentation Strategy
- ExDoc for shared NRPS modules.
- Shared contract reference and migration notes under `docs/`.
- Changelog required for shared contract changes.

## 11. Decisions
1. Unsupported filters:
Decision: standardized explicit rejection in shared contract.
Implementation impact: prevents silent divergence between roles.

2. Pagination metadata model:
Decision: shared normalized shape with adapter/client local translation.
Implementation impact: consistent external semantics with internal flexibility.
