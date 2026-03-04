# Implementation Plan

## Phase 0 - Alignment and Baseline Audit
### Deliverables
- Approved core PRD/FDD baseline and audited gap list against current modules.

### Tasks
- [ ] Build a core conformance matrix (spec requirement -> current module -> status).
- [ ] Enumerate breaking API changes and define final target API signatures.
- [ ] Confirm canonical error map schema and reason atom catalog.
- [ ] Define provider behavior contract changes and adapter migration expectations.
- [ ] Build documentation inventory for all public modules/APIs and required guides under `docs/`.

### Verification
- [ ] Gap matrix reviewed by maintainers.
- [ ] Target API and error catalog approved.

## Phase 1 - API Unification and Contract Refactor
### Deliverables
- Unified top-level `Tool` and `Platform` APIs with consistent tuple contracts.

### Tasks
- [ ] Implement new `Lti_1p3.Tool` core API functions and migrate call sites.
- [ ] Implement new `Lti_1p3.Platform` core API functions and migrate call sites.
- [ ] Introduce shared core error helpers and replace ad-hoc error map creation.
- [ ] Update behavior contracts and reference memory provider implementation.
- [ ] Fix naming inconsistencies (including validator path/module naming).

### Verification
- [ ] Core unit tests pass with new API contracts.
- [ ] Provider behavior conformance tests pass.

## Phase 2 - Launch Validation Hardening
### Deliverables
- Fully hardened tool/platform core validation pipelines.

### Tasks
- [ ] Refactor validation into stage-based shared modules (state, registration, jwt, timestamps, deployment, nonce, message).
- [ ] Correct and harden issuer/audience/time validations.
- [ ] Add launch message dispatcher scaffolding for resource and deep-linking requests.
- [ ] Ensure algorithm constraints and kid resolution failures are explicit and tested.
- [ ] Add deterministic failure reason coverage for all negative paths.

### Verification
- [ ] Security-focused regression suite passes.
- [ ] Stage-level failure reason assertions pass across test matrix.

## Phase 3 - Observability and Migration Assets
### Deliverables
- Telemetry coverage and migration documentation for integrators.

### Tasks
- [ ] Add telemetry events and structured logs for all validation stages.
- [ ] Add docs for new API usage (tool + platform) and migration guide.
- [ ] Publish provider adapter migration checklist and sample contract tests.
- [ ] Update README and docs pages to new API.
- [ ] Ensure `@moduledoc`, `@doc`, and `@spec` are complete for all public core modules/functions.

### Verification
- [ ] Telemetry assertions validated in tests.
- [ ] Documentation examples compile in doctests or integration checks.
- [ ] `mix docs` completes with full public API coverage and required `docs/` guides present.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual acceptance evidence for core launch interoperability.

### Tasks
- [ ] Execute manual tool launch flow against at least one external LMS sandbox.
- [ ] Execute manual platform authorization flow against tool sandbox.
- [ ] Validate failure handling paths (invalid state, nonce replay, wrong deployment, stale token).
- [ ] Capture QA report with pass/fail and remediation items.

### Verification
- [ ] Manual QA report approved.
- [ ] Remaining issues are tracked and triaged.

## PR Grouping
- PR Group 1: Phases 0-1
- PR Group 2: Phase 2
- PR Group 3: Phases 3-4
