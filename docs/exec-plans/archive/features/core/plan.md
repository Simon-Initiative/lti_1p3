# Implementation Plan

## Phase 0 - Alignment and Baseline Audit
### Deliverables
- Approved core PRD/FDD baseline and audited gap list against current modules.

### Tasks
- [x] Build a core conformance matrix (spec requirement -> current module -> status).
- [x] Enumerate breaking API changes and define final target API signatures.
- [x] Confirm canonical error map schema and reason atom catalog.
- [x] Define provider behavior contract changes and adapter migration expectations.
- [x] Build documentation inventory for all public modules/APIs and required guides under `docs/`.

### Verification
- [x] Gap matrix reviewed by maintainers.
- [x] Target API and error catalog approved.

## Phase 1 - API Unification and Contract Refactor
### Deliverables
- Unified top-level `Tool` and `Platform` APIs with consistent tuple contracts.

### Tasks
- [x] Implement new `Lti_1p3.Tool` core API functions and migrate call sites.
- [x] Implement new `Lti_1p3.Platform` core API functions and migrate call sites.
- [x] Introduce shared core error helpers and replace ad-hoc error map creation.
- [x] Update behavior contracts and reference memory provider implementation.
- [x] Fix naming inconsistencies (including validator path/module naming).

### Verification
- [x] Core unit tests pass with new API contracts.
- [x] Provider behavior conformance tests pass.

## Phase 2 - Launch Validation Hardening
### Deliverables
- Fully hardened tool/platform core validation pipelines.

### Tasks
- [x] Refactor validation into stage-based shared modules (state, registration, jwt, timestamps, deployment, nonce, message).
- [x] Correct and harden issuer/audience/time validations.
- [x] Add launch message dispatcher scaffolding for resource and deep-linking requests.
- [x] Ensure algorithm constraints and kid resolution failures are explicit and tested.
- [x] Add deterministic failure reason coverage for all negative paths.

### Verification
- [x] Security-focused regression suite passes.
- [x] Stage-level failure reason assertions pass across test matrix.

## Phase 3 - Observability and Migration Assets
### Deliverables
- Telemetry coverage and migration documentation for integrators.

### Tasks
- [x] Add telemetry events and structured logs for all validation stages.
- [x] Add docs for new API usage (tool + platform) and migration guide.
- [x] Publish provider adapter migration checklist and sample contract tests.
- [x] Update README and docs pages to new API.
- [x] Ensure `@moduledoc`, `@doc`, and `@spec` are complete for all public core modules/functions.

### Verification
- [x] Telemetry assertions validated in tests.
- [x] Documentation examples compile in doctests or integration checks.
- [x] `mix docs` completes with full public API coverage and required `docs/` guides present.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual acceptance evidence for core launch interoperability.

### Tasks
- [ ] Execute manual tool launch flow against at least one external LMS sandbox.
- [ ] Execute manual platform authorization flow against tool sandbox.
- [x] Validate failure handling paths (invalid state, nonce replay, wrong deployment, stale token).
- [x] Capture QA report with pass/fail and remediation items.

### Verification
- [ ] Manual QA report approved.
- [x] Remaining issues are tracked and triaged.

## PR Grouping
- PR Group 1: Phases 0-1
- PR Group 2: Phase 2
- PR Group 3: Phases 3-4
