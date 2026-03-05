# Implementation Plan

## Phase 0 - Deep Linking Tool Baseline
### Deliverables
- Deep-linking tool requirement matrix and target API signatures.

### Tasks
- [x] Map deep-linking tool requirements and current gaps.
- [x] Finalize request/settings/item/response API contracts.
- [x] Finalize reason atom catalog for validation/build failures.
- [x] Identify utility extraction seams in tool modules.

### Verification
- [x] Requirement matrix approved.
- [x] API signatures and reason atoms approved.

## Phase 1 - Request Validation and Settings
### Deliverables
- Launch validation and typed settings parsing.

### Tasks
- [x] Implement request validator and settings parser.
- [x] Integrate deep-linking request validation into dispatch.
- [x] Normalize errors to structured maps.
- [x] Add unit tests for positive and negative claim paths.

### Verification
- [x] Dispatch and validation tests pass.
- [x] Structured error mapping tests pass.

## Phase 2 - Content Items and Response Builder
### Deliverables
- Typed content item API and signed deep-link response generation.

### Tasks
- [x] Implement content item builders and subtype validation.
- [x] Implement response claim assembly and conditional `data` handling.
- [x] Integrate JWT signing helper.
- [x] Implement compatibility profile hooks.

### Verification
- [x] Integration tests pass for response claims/signatures.
- [x] Unsupported subtype behavior tests pass.

## Phase 3 - Hardening and Extraction Readiness
### Deliverables
- Production-ready observability plus reusable module extraction plan.

### Tasks
- [x] Add telemetry events and structured logs.
- [x] Document utility candidates with concrete call sites and tests.
- [x] Extract proven duplicate helpers into reusable modules where appropriate.
- [x] Update docs with tool deep-linking examples and utility usage notes.

### Verification
- [x] Telemetry assertions pass.
- [x] Reusable helpers are covered by focused unit tests.
- [x] `mix docs` completes with current guides.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual deep-linking tool interoperability report.

### Tasks
- [ ] Validate tool behavior against at least 2 LMS sandboxes.
- [ ] Validate response submission with representative item types.
- [ ] Validate negative paths (missing claims, disabled types, bad signatures).
- [x] Record QA findings and remediation ownership.

### Verification
- [ ] QA report approved.
- [ ] Critical defects triaged.
