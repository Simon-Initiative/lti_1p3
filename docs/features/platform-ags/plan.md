# Implementation Plan

## Phase 0 - AGS Platform Baseline
### Deliverables
- AGS platform requirement matrix and finalized API surface.

### Tasks
- [x] Define operation/scope/context authorization matrix.
- [x] Review tool AGS modules for reusable helper candidates.
- [x] Finalize platform typed models and error reason catalog.
- [x] Finalize platform AGS docs inventory.

### Verification
- [x] Requirement matrix approved.
- [x] Reusable helper candidate list approved.

## Phase 1 - Authorization and Core Models
### Deliverables
- Authorization pipeline and model definitions.

### Tasks
- [x] Implement scope/context/deployment policy helpers.
- [x] Implement core platform AGS structs.
- [x] Normalize error mapping for all public operations.
- [x] Add unit tests for authorization and error paths.

### Verification
- [x] Authorization and error tests pass.
- [x] Model serialization/validation tests pass.

## Phase 2 - Operations and Reuse
### Deliverables
- Complete platform line item/score/result operations with minimized duplication.

### Tasks
- [x] Implement line item list/create/read/update/delete operations.
- [x] Implement score ingestion and result retrieval operations.
- [x] Extract duplicated logic from tool AGS into reusable modules and replace duplicate platform logic with those modules.
- [x] Add integration tests for success and denial paths.

### Verification
- [x] Integration tests pass for all operations.
- [x] Duplicated helper implementations are replaced by reusable modules where applicable.

## Phase 3 - Hardening and Documentation
### Deliverables
- Production-ready observability and docs.

### Tasks
- [x] Add telemetry events and structured logs.
- [x] Validate reusable module usage across tool/platform AGS paths.
- [x] Update docs with platform AGS examples and integration guidance.
- [x] Ensure `@moduledoc`, `@doc`, and `@spec` coverage.

### Verification
- [x] Telemetry assertions pass.
- [x] `mix docs` completes with current platform AGS guides.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual AGS platform interoperability report.

### Tasks
- [ ] Validate platform AGS behavior with at least 2 reference tools.
- [x] Validate negative paths (scope denial, bad context, malformed payload).
- [x] Validate reusable module behavior in tool and platform AGS flows.
- [x] Record QA findings and remediation ownership.

### Verification
- [ ] QA report approved.
- [ ] Critical defects triaged.
