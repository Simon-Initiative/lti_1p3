# Implementation Plan

## Phase 0 - AGS Tool Baseline
### Deliverables
- AGS tool requirement matrix and finalized API surface.

### Tasks
- [x] Map AGS tool operations and required scopes.
- [x] Audit current implementation and enumerate missing behavior.
- [x] Finalize typed models and error reason catalog.
- [x] Define candidate utility extraction seams in tool modules.

### Verification
- [x] Requirement matrix approved.
- [x] API signatures and reason atoms approved.

## Phase 1 - Models, Parsing, and Scope Enforcement
### Deliverables
- Typed structs and deterministic preflight authorization.

### Tasks
- [x] Implement/refresh endpoint, line item, score, result, and page structs.
- [x] Implement claim parser and scope policy.
- [x] Normalize all public errors to structured maps.
- [x] Add unit tests for parsing/scope/error branches.

### Verification
- [x] Unit tests pass for parser, scope policy, and error mapping.
- [x] Existing behavior regressions are covered.

## Phase 2 - Tool AGS Operations
### Deliverables
- Full line item, score, and result operation coverage.

### Tasks
- [x] Implement line item list/create/read/update/delete operations.
- [x] Implement score posting validation and execution.
- [x] Implement result retrieval and pagination traversal.
- [x] Implement compatibility profile hooks.

### Verification
- [x] Integration tests pass for success/failure branches.
- [x] Pagination and scope matrix tests pass.

## Phase 3 - Hardening and Extraction Readiness
### Deliverables
- Production-ready observability plus reusable module extraction plan.

### Tasks
- [x] Add telemetry events and structured logs.
- [x] Document utility candidates with concrete call sites and tests.
- [x] Extract proven duplicate helpers into reusable modules where appropriate.
- [x] Update docs with tool AGS examples and utility usage notes.

### Verification
- [x] Telemetry assertions pass.
- [x] Reusable helpers are covered by focused unit tests.
- [x] `mix docs` completes with current guides.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual AGS tool interoperability report.

### Tasks
- [ ] Validate line item lifecycle in at least 2 LMS sandboxes.
- [ ] Validate score publish and result retrieval paths.
- [ ] Validate denial/error paths (scope, token, payload, timeout).
- [ ] Record QA findings and remediation ownership.

### Verification
- [ ] QA report approved.
- [ ] Critical defects triaged.
