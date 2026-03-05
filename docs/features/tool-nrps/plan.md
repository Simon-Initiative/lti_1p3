# Implementation Plan

## Phase 0 - NRPS Tool Baseline
### Deliverables
- NRPS tool requirement matrix and target API signatures.

### Tasks
- [x] Map NRPS requirements, scope matrix, and current gaps.
- [x] Finalize page/stream/fetch-all API contracts.
- [x] Finalize typed models and reason atom catalog.
- [x] Identify utility extraction seams for link/filter helpers.

### Verification
- [x] Requirement matrix approved.
- [x] API contracts and reason atoms approved.

## Phase 1 - Models, Parsing, and Scope Enforcement
### Deliverables
- Typed endpoint/membership/page models and deterministic scope checks.

### Tasks
- [x] Implement claim parser and endpoint model validation.
- [x] Implement membership model and role normalization.
- [x] Implement scope preflight and structured errors.
- [x] Add unit tests for parser/scope/error branches.

### Verification
- [x] Unit tests pass for parser/scope/normalization.
- [x] Regression tests cover known scope issues.

## Phase 2 - Pagination and Retrieval APIs
### Deliverables
- Full pagination traversal with stream and eager retrieval modes.

### Tasks
- [x] Implement `Link` header parser and page traversal.
- [x] Implement stream API.
- [x] Implement eager fetch-all with max-page guard.
- [x] Implement optional filter and limit support.

### Verification
- [x] Integration tests pass for multi-page and filter paths.
- [x] Max-page guard behavior is verified.

## Phase 3 - Hardening and Extraction Readiness
### Deliverables
- Production-ready observability plus reusable module extraction plan.

### Tasks
- [x] Add telemetry events and structured logs.
- [x] Document utility candidates with concrete call sites and tests.
- [x] Extract proven duplicate helpers into reusable modules where appropriate.
- [x] Update docs with tool NRPS examples and utility usage notes.

### Verification
- [x] Telemetry/retry tests pass.
- [x] Reusable helpers are covered by focused unit tests.
- [x] `mix docs` completes with current guides.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual NRPS tool interoperability report.

### Tasks
- [ ] Validate roster retrieval with at least 2 LMS sandboxes.
- [ ] Validate pagination and filters.
- [x] Validate negative paths (scope denial, malformed payload, token expiry).
- [x] Record QA findings and remediation ownership.

### Verification
- [ ] QA report approved.
- [ ] Critical defects triaged.
