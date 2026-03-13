# Implementation Plan

## Phase 0 - AGS Conformance Baseline
### Deliverables
- AGS requirement matrix and operation/scope map.

### Tasks
- [ ] Build AGS protocol matrix (lineitems, scores, results, required media types/scopes).
- [ ] Audit current AGS module behavior and identify incompatibilities.
- [ ] Define final AGS API signatures and error map schema.
- [ ] Build AGS documentation inventory for public APIs and required guides under `docs/`.

### Verification
- [ ] AGS matrix reviewed and approved.
- [ ] API signatures approved.

## Phase 1 - AGS API and Model Refactor
### Deliverables
- New AGS typed models and operation functions.

### Tasks
- [ ] Implement endpoint/lineitem/score/result/page structs.
- [ ] Implement claim parsing and validation helpers.
- [ ] Implement scope policy module and preflight scope checks.
- [ ] Replace string-based errors with structured reason maps.

### Verification
- [ ] Unit tests for models and scope policy pass.
- [ ] Existing AGS tests migrated to new API.

## Phase 2 - Full Operation Coverage
### Deliverables
- Complete AGS CRUD + score + results operation support.

### Tasks
- [ ] Implement list/create/update/delete line item operations.
- [ ] Implement score publish with payload validation.
- [ ] Implement results retrieval with pagination traversal.
- [ ] Add retry classification and timeout handling.

### Verification
- [ ] Integration tests pass for success and failure cases.
- [ ] Pagination and scope enforcement tests pass.

## Phase 3 - Hardening and Documentation
### Deliverables
- Production-ready AGS observability and docs.

### Tasks
- [ ] Add telemetry events and structured logs for AGS operations.
- [ ] Add compatibility notes for LMS-specific AGS quirks.
- [ ] Update README/docs with end-to-end AGS examples.
- [ ] Ensure `@moduledoc`, `@doc`, and `@spec` coverage for all public AGS modules/functions.

### Verification
- [ ] Telemetry assertions pass in tests.
- [ ] Docs examples validated in test environment.
- [ ] `mix docs` completes and AGS guides under `docs/` are up to date.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual AGS interoperability report.

### Tasks
- [ ] Validate line item lifecycle against at least 2 LMS sandboxes.
- [ ] Validate score publish and result retrieval flows.
- [ ] Verify negative paths (invalid scope, token expiry, malformed payload).
- [ ] Record pass/fail outcomes and follow-up remediation.

### Verification
- [ ] Manual QA report approved.
- [ ] Blocking issues captured with owners.
