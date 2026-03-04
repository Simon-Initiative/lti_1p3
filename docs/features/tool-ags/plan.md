# Implementation Plan

## Phase 0 - Tool AGS Baseline and Contracts
### Deliverables
- Tool AGS requirement matrix and finalized API contracts.

### Tasks
- [ ] Map AGS tool requirements and operation/scope matrix.
- [ ] Audit current `Lti_1p3.Tool.Services.AGS` gaps and incompatibilities.
- [ ] Finalize typed models and structured error schema.
- [ ] Build tool AGS docs inventory for public APIs and guides.

### Verification
- [ ] Requirement matrix approved.
- [ ] API signatures and reason atom catalog approved.

## Phase 1 - Models, Claim Parsing, and Scope Policy
### Deliverables
- Typed endpoint/line item/score/result/page models and scope preflight.

### Tasks
- [ ] Implement/refresh AGS structs and claim parser.
- [ ] Implement operation-to-scope policy module.
- [ ] Replace string errors with structured error maps.
- [ ] Add unit tests for parsing and scope enforcement.

### Verification
- [ ] Parsing and scope tests pass.
- [ ] Legacy behavior compatibility tests added where needed.

## Phase 2 - Full Tool Operation Coverage
### Deliverables
- Complete tool-side line item, score, and result operations.

### Tasks
- [ ] Implement line item list/create/update/delete/read behaviors.
- [ ] Implement score publish validation and execution.
- [ ] Implement results retrieval with pagination traversal.
- [ ] Add timeout handling and retryability classification.

### Verification
- [ ] Integration tests cover success and failure branches.
- [ ] Pagination and scope matrix tests pass.

## Phase 3 - Hardening and Documentation
### Deliverables
- Production-ready telemetry/logging and finalized docs.

### Tasks
- [ ] Add telemetry events, spans, and structured logs.
- [ ] Implement compatibility policy profiles for LMS quirks.
- [ ] Update README/docs with AGS tool examples.
- [ ] Ensure `@moduledoc`, `@doc`, and `@spec` coverage.

### Verification
- [ ] Telemetry assertions pass.
- [ ] Documentation examples validated.
- [ ] `mix docs` completes with AGS tool guides up to date.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual tool AGS interoperability report.

### Tasks
- [ ] Validate line item lifecycle against at least 2 LMS sandboxes.
- [ ] Validate score publish and result retrieval.
- [ ] Validate negative paths (scope denial, token expiry, malformed payload).
- [ ] Capture pass/fail outcomes and remediation backlog.

### Verification
- [ ] QA report approved.
- [ ] Critical defects triaged with owners.
