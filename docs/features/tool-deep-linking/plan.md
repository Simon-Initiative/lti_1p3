# Implementation Plan

## Phase 0 - Tool Deep Linking Baseline
### Deliverables
- Tool deep-linking requirement matrix and API contracts.

### Tasks
- [ ] Map tool deep-linking spec requirements and current gaps.
- [ ] Finalize request/settings/item/response contracts.
- [ ] Define reason atom catalog for validation/build failures.
- [ ] Build docs inventory for tool deep-linking APIs and guides.

### Verification
- [ ] Requirement matrix approved.
- [ ] API contracts approved.

## Phase 1 - Request Validation and Dispatch
### Deliverables
- `LtiDeepLinkingRequest` support integrated in tool launch path.

### Tasks
- [ ] Implement request validator and settings parser.
- [ ] Integrate deep-linking validator into message dispatch.
- [ ] Add claim-level positive and negative tests.
- [ ] Normalize validation errors to structured maps.

### Verification
- [ ] Dispatch tests pass.
- [ ] Claim validation tests pass.

## Phase 2 - Content Items and Response Builder
### Deliverables
- Typed content item API and signed deep-linking response generation.

### Tasks
- [ ] Implement content item builders and subtype validation.
- [ ] Implement response claim assembly and data correlation handling.
- [ ] Implement JWT signing helper integration.
- [ ] Add compatibility controls for subtype restrictions.

### Verification
- [ ] Integration tests pass for response token claims/signatures.
- [ ] Unsupported subtype tests pass.

## Phase 3 - Hardening and Documentation
### Deliverables
- Telemetry/logging and complete tool deep-linking docs.

### Tasks
- [ ] Add telemetry events and structured logs.
- [ ] Add README/docs examples for request and response flows.
- [ ] Ensure `@moduledoc`, `@doc`, and `@spec` coverage.
- [ ] Validate docs examples in tests.

### Verification
- [ ] Telemetry assertions pass.
- [ ] `mix docs` completes with guides current.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual tool deep-linking interoperability report.

### Tasks
- [ ] Validate request handling against at least 2 LMS sandboxes.
- [ ] Validate response submission with representative item types.
- [ ] Validate negative paths (missing claims, disabled types, bad signatures).
- [ ] Record QA outcomes and remediation backlog.

### Verification
- [ ] QA report approved.
- [ ] Critical defects triaged.
