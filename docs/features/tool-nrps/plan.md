# Implementation Plan

## Phase 0 - Tool NRPS Baseline
### Deliverables
- Tool NRPS requirement matrix and target API signatures.

### Tasks
- [ ] Map tool NRPS spec requirements and current module/test gaps.
- [ ] Correct required scope definitions and compatibility notes.
- [ ] Finalize page/stream/fetch-all API contracts.
- [ ] Build docs inventory for tool NRPS APIs and guides.

### Verification
- [ ] Matrix and scope policy approved.
- [ ] API contracts approved.

## Phase 1 - Contracts and Parsing
### Deliverables
- Typed endpoint/membership models and structured errors.

### Tasks
- [ ] Implement endpoint claim parser and version validation.
- [ ] Implement membership model and role normalization helpers.
- [ ] Implement structured NRPS error mapper.
- [ ] Update `required_scopes/0` behavior and tests.

### Verification
- [ ] Parsing/scope/normalization tests pass.
- [ ] Regression tests cover legacy scope bug.

## Phase 2 - Pagination and Retrieval Modes
### Deliverables
- Page traversal, stream API, and eager fetch support.

### Tasks
- [ ] Implement `Link` header pagination traversal.
- [ ] Implement lazy stream API.
- [ ] Implement eager all-members retrieval with max-page guard.
- [ ] Add optional filter/limit parameter support.

### Verification
- [ ] Integration tests pass for multi-page and filters.
- [ ] Max-page and memory behavior tests pass.

## Phase 3 - Hardening and Documentation
### Deliverables
- Telemetry/retry hardening and complete docs.

### Tasks
- [ ] Add telemetry events and structured logs.
- [ ] Implement bounded retry for transient failures.
- [ ] Update README/docs with tool NRPS examples.
- [ ] Ensure public API `@moduledoc`/`@doc`/`@spec` coverage.

### Verification
- [ ] Telemetry/retry tests pass.
- [ ] `mix docs` completes with guides current.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual tool NRPS interoperability report.

### Tasks
- [ ] Validate roster retrieval with at least 2 LMS sandboxes.
- [ ] Validate pagination and filter behavior.
- [ ] Validate negative paths (scope denial, bad JSON, token expiry).
- [ ] Record QA outcomes and remediation backlog.

### Verification
- [ ] QA report approved.
- [ ] Critical defects triaged.
