# Implementation Plan

## Phase 0 - AGS Tool Baseline
### Deliverables
- AGS tool requirement matrix and finalized API surface.

### Tasks
- [ ] Map AGS tool operations and required scopes.
- [ ] Audit current implementation and enumerate missing behavior.
- [ ] Finalize typed models and error reason catalog.
- [ ] Define candidate utility extraction seams in tool modules.

### Verification
- [ ] Requirement matrix approved.
- [ ] API signatures and reason atoms approved.

## Phase 1 - Models, Parsing, and Scope Enforcement
### Deliverables
- Typed structs and deterministic preflight authorization.

### Tasks
- [ ] Implement/refresh endpoint, line item, score, result, and page structs.
- [ ] Implement claim parser and scope policy.
- [ ] Normalize all public errors to structured maps.
- [ ] Add unit tests for parsing/scope/error branches.

### Verification
- [ ] Unit tests pass for parser, scope policy, and error mapping.
- [ ] Existing behavior regressions are covered.

## Phase 2 - Tool AGS Operations
### Deliverables
- Full line item, score, and result operation coverage.

### Tasks
- [ ] Implement line item list/create/read/update/delete operations.
- [ ] Implement score posting validation and execution.
- [ ] Implement result retrieval and pagination traversal.
- [ ] Implement compatibility profile hooks.

### Verification
- [ ] Integration tests pass for success/failure branches.
- [ ] Pagination and scope matrix tests pass.

## Phase 3 - Hardening and Extraction Readiness
### Deliverables
- Production-ready observability plus reusable module extraction plan.

### Tasks
- [ ] Add telemetry events and structured logs.
- [ ] Document utility candidates with concrete call sites and tests.
- [ ] Extract proven duplicate helpers into reusable modules where appropriate.
- [ ] Update docs with tool AGS examples and utility usage notes.

### Verification
- [ ] Telemetry assertions pass.
- [ ] Reusable helpers are covered by focused unit tests.
- [ ] `mix docs` completes with current guides.

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
