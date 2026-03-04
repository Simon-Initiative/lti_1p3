# Implementation Plan

## Phase 0 - NRPS Audit and Target API
### Deliverables
- NRPS requirement matrix and corrected scope policy specification.

### Tasks
- [ ] Map NRPS spec requirements to current module/test coverage.
- [ ] Correct required scope definitions and document compatibility assumptions.
- [ ] Finalize target API signatures for page, stream, and full-fetch modes.
- [ ] Build NRPS documentation inventory for public APIs and required guides under `docs/`.

### Verification
- [ ] Matrix and scope policy approved.
- [ ] API signatures approved.

## Phase 1 - NRPS Contracts and Parsing
### Deliverables
- Typed NRPS endpoint and membership models with structured errors.

### Tasks
- [ ] Implement endpoint claim parser and service version validation.
- [ ] Implement membership model and role normalization helpers.
- [ ] Implement structured error mapper for NRPS operations.
- [ ] Update `required_scopes/0` and scope validation behavior.

### Verification
- [ ] Unit tests for parsing/scope/normalization pass.
- [ ] Scope regression tests cover incorrect legacy behavior.

## Phase 2 - Pagination and Retrieval Modes
### Deliverables
- Full pagination support and retrieval APIs.

### Tasks
- [ ] Implement page retrieval with `Link` header parsing.
- [ ] Implement lazy stream API over page traversal.
- [ ] Implement eager all-members fetch with max-page safeguards.
- [ ] Add support for optional filters and limit overrides.

### Verification
- [ ] Integration tests pass for multi-page and filtered retrieval.
- [ ] Memory usage and max-page guard behavior validated.

## Phase 3 - Hardening and Docs
### Deliverables
- Production-ready NRPS telemetry, retries, and docs.

### Tasks
- [ ] Add telemetry events and structured logging.
- [ ] Implement bounded retry behavior for transient failures.
- [ ] Update README/docs with NRPS integration examples.
- [ ] Ensure `@moduledoc`, `@doc`, and `@spec` coverage for all public NRPS modules/functions.

### Verification
- [ ] Telemetry and retry behavior tests pass.
- [ ] Documentation examples validated.
- [ ] `mix docs` completes and NRPS guides under `docs/` are complete.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual NRPS interoperability report.

### Tasks
- [ ] Validate roster retrieval against at least 2 LMS sandboxes.
- [ ] Validate multi-page traversal and filter behavior.
- [ ] Validate negative paths (scope denial, token expiry, bad JSON).
- [ ] Capture QA report and remediation items.

### Verification
- [ ] Manual QA report approved.
- [ ] Critical defects triaged before merge.
