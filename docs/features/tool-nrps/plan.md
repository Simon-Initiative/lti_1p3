# Implementation Plan

## Phase 0 - NRPS Tool Baseline
### Deliverables
- NRPS tool requirement matrix and target API signatures.

### Tasks
- [ ] Map NRPS requirements, scope matrix, and current gaps.
- [ ] Finalize page/stream/fetch-all API contracts.
- [ ] Finalize typed models and reason atom catalog.
- [ ] Identify utility extraction seams for link/filter helpers.

### Verification
- [ ] Requirement matrix approved.
- [ ] API contracts and reason atoms approved.

## Phase 1 - Models, Parsing, and Scope Enforcement
### Deliverables
- Typed endpoint/membership/page models and deterministic scope checks.

### Tasks
- [ ] Implement claim parser and endpoint model validation.
- [ ] Implement membership model and role normalization.
- [ ] Implement scope preflight and structured errors.
- [ ] Add unit tests for parser/scope/error branches.

### Verification
- [ ] Unit tests pass for parser/scope/normalization.
- [ ] Regression tests cover known scope issues.

## Phase 2 - Pagination and Retrieval APIs
### Deliverables
- Full pagination traversal with stream and eager retrieval modes.

### Tasks
- [ ] Implement `Link` header parser and page traversal.
- [ ] Implement stream API.
- [ ] Implement eager fetch-all with max-page guard.
- [ ] Implement optional filter and limit support.

### Verification
- [ ] Integration tests pass for multi-page and filter paths.
- [ ] Max-page guard behavior is verified.

## Phase 3 - Hardening and Extraction Readiness
### Deliverables
- Production-ready observability plus reusable module extraction plan.

### Tasks
- [ ] Add telemetry events and structured logs.
- [ ] Document utility candidates with concrete call sites and tests.
- [ ] Extract proven duplicate helpers into reusable modules where appropriate.
- [ ] Update docs with tool NRPS examples and utility usage notes.

### Verification
- [ ] Telemetry/retry tests pass.
- [ ] Reusable helpers are covered by focused unit tests.
- [ ] `mix docs` completes with current guides.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual NRPS tool interoperability report.

### Tasks
- [ ] Validate roster retrieval with at least 2 LMS sandboxes.
- [ ] Validate pagination and filters.
- [ ] Validate negative paths (scope denial, malformed payload, token expiry).
- [ ] Record QA findings and remediation ownership.

### Verification
- [ ] QA report approved.
- [ ] Critical defects triaged.
