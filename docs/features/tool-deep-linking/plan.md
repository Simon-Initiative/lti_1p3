# Implementation Plan

## Phase 0 - Deep Linking Tool Baseline
### Deliverables
- Deep-linking tool requirement matrix and target API signatures.

### Tasks
- [ ] Map deep-linking tool requirements and current gaps.
- [ ] Finalize request/settings/item/response API contracts.
- [ ] Finalize reason atom catalog for validation/build failures.
- [ ] Identify utility extraction seams in tool modules.

### Verification
- [ ] Requirement matrix approved.
- [ ] API signatures and reason atoms approved.

## Phase 1 - Request Validation and Settings
### Deliverables
- Launch validation and typed settings parsing.

### Tasks
- [ ] Implement request validator and settings parser.
- [ ] Integrate deep-linking request validation into dispatch.
- [ ] Normalize errors to structured maps.
- [ ] Add unit tests for positive and negative claim paths.

### Verification
- [ ] Dispatch and validation tests pass.
- [ ] Structured error mapping tests pass.

## Phase 2 - Content Items and Response Builder
### Deliverables
- Typed content item API and signed deep-link response generation.

### Tasks
- [ ] Implement content item builders and subtype validation.
- [ ] Implement response claim assembly and conditional `data` handling.
- [ ] Integrate JWT signing helper.
- [ ] Implement compatibility profile hooks.

### Verification
- [ ] Integration tests pass for response claims/signatures.
- [ ] Unsupported subtype behavior tests pass.

## Phase 3 - Hardening and Extraction Readiness
### Deliverables
- Production-ready observability plus reusable module extraction plan.

### Tasks
- [ ] Add telemetry events and structured logs.
- [ ] Document utility candidates with concrete call sites and tests.
- [ ] Extract proven duplicate helpers into reusable modules where appropriate.
- [ ] Update docs with tool deep-linking examples and utility usage notes.

### Verification
- [ ] Telemetry assertions pass.
- [ ] Reusable helpers are covered by focused unit tests.
- [ ] `mix docs` completes with current guides.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual deep-linking tool interoperability report.

### Tasks
- [ ] Validate tool behavior against at least 2 LMS sandboxes.
- [ ] Validate response submission with representative item types.
- [ ] Validate negative paths (missing claims, disabled types, bad signatures).
- [ ] Record QA findings and remediation ownership.

### Verification
- [ ] QA report approved.
- [ ] Critical defects triaged.
