# Functional Design Document

## 1. Design Overview
- Scope covered: shared deep-linking contract modules and conformance tests.
- Assumptions:
  - Role tracks own request/response runtime logic.
  - Shared contract targets interoperability-critical semantics only.

## 2. System Context and Boundaries
- In-scope components:
  - Correlation contract utilities.
  - Content item type catalog/normalization.
  - Shared error and telemetry naming contract.
  - Shared compatibility policy contract.
  - Contract test helpers.
- Out-of-scope components:
  - Tool response-building logic.
  - Platform request/response orchestration.

## 3. Architecture
- High-level flow:
  - Shared contract definitions -> role-specific consumption -> shared conformance tests.
- Module responsibilities:
  - `Lti_1p3.Shared.DeepLinking.Correlation`
  - `Lti_1p3.Shared.DeepLinking.ContentItemCatalog`
  - `Lti_1p3.Shared.DeepLinking.Errors`
  - `Lti_1p3.Shared.DeepLinking.Telemetry`
  - `Lti_1p3.Shared.DeepLinking.CompatibilityPolicy`
  - `Lti_1p3.Shared.DeepLinking.ContractTest`

## 4. Data Design
- Schema changes: none.
- Data lifecycle: static constants and pure validation helpers.
- Migration strategy: additive changes with migration notes for renamed reasons/types.

## 5. Interfaces and Contracts
- `validate_correlation(actual, expected, opts) -> :ok | {:error, error}`
- `normalize_content_item(item, opts) -> {:ok, normalized} | {:error, error}`
- `error(reason, attrs) -> %{reason:, msg:, details: map()}`
- `telemetry_event(stage, outcome) -> event_name`

## 6. Runtime Behavior
- Deterministic, pure helper modules.
- No process/supervision impact.

## 7. Security and Compliance
- Correlation helpers enforce strict defaults.
- Shared error helpers redact sensitive fields by default.

## 8. Observability and Operations
- Shared telemetry keys for request validation/build/consume outcomes.
- Shared docs for alert/dashboard consistency.

## 9. Testing Strategy
- Unit: correlation logic, subtype catalogs, error metadata.
- Contract: reusable conformance tests for tool/platform modules.
- Integration: verify both role tracks emit shared telemetry naming.

## 10. Documentation Strategy
- ExDoc for shared deep-linking modules.
- Shared contract reference plus migration guide under `docs/`.
- Changelog required for contract changes.

## 11. Decisions
1. Correlation default mode:
Decision: strict by default with explicit tolerant profile.
Implementation impact: predictable validation with controlled flexibility.

2. Unsupported subtype behavior:
Decision: shared policy defines strict reject and tolerant skip semantics.
Implementation impact: role tracks can choose mode but semantics stay consistent.
