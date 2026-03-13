# Functional Design Document

## 1. Design Overview
- Scope covered: Certification readiness architecture, conformance harness, QA workflow, and release gating.
- Assumptions:
  - Domain features (core/AGS/NRPS/deep-linking) are implemented or in-flight with stable APIs.
  - CI environment can run full test matrix and preserve artifacts.

## 2. System Context and Boundaries
- In-scope components:
  - Conformance matrix artifacts under docs.
  - Domain-tagged automated test suites.
  - Manual QA scripts/checklists and certification dossier template.
  - CI certification pipeline configuration and release gates.
- Out-of-scope components:
  - External 1EdTech portal submission workflow.
  - Vendor contractual/legal process handling.

## 3. Architecture
- High-level flow:
  - Spec requirement catalog -> test mapping -> automated run -> manual validation -> artifact package -> release gate decision.
- Context/module responsibilities:
  - `docs/certification/conformance-matrix.md`: requirement mapping source of truth.
  - `test/conformance/**`: automated conformance suites by domain.
  - `docs/certification/manual-qa/**`: manual scripts and result templates.
  - CI job `certification_profile`: runs domain suites, coverage, and artifacts.
- Supervision tree impact:
  - None.

## 4. Data Design
- Schema changes:
  - None required.
- Data lifecycle:
  - Conformance outputs stored as CI artifacts and versioned docs snapshots.
- Migration/backfill strategy:
  - Introduce matrix incrementally, backfilling existing tests into requirement mappings.

## 5. Interfaces and Contracts
- Internal APIs:
  - Conformance helper macros/tags for spec requirement IDs.
  - Test metadata contract: each test references requirement ID(s).
- External APIs/webhooks:
  - Optional LMS sandbox endpoints used in manual QA.
- Event/message formats:
  - CI summary JSON: domain, pass/fail counts, coverage, blocking failures.

## 6. Runtime Behavior
- Process model:
  - Test execution in standard ExUnit and CI workflows.
- Concurrency model:
  - Parallel test execution where deterministic; isolated state for conformance tests.
- Failure handling/retries:
  - Retries only for flaky external sandbox integration jobs, never for deterministic local conformance tests.
- Timeouts/circuit breakers:
  - Explicit suite-level timeouts and sandbox operation timeout budgets.

## 7. Security and Compliance
- AuthN/AuthZ impact:
  - Include explicit security conformance tests for signature, nonce, scope, and claim validation.
- Data protection:
  - Redact secrets/tokens from logs and artifacts.
- Audit/logging requirements:
  - Keep signed build metadata and immutable artifact references for each certification candidate run.

## 8. Observability and Operations
- Metrics:
  - `conformance.pass_rate`, `conformance.requirement_coverage`, `certification.gate_status`.
- Logs:
  - CI summary logs with failing requirement IDs.
- Tracing:
  - Not required.
- Alerts/runbooks:
  - Alert on gate failure in release branches and provide runbook for triage.

## 9. Testing Strategy
- Unit:
  - Requirement tag helpers and matrix consistency checks.
- Integration:
  - End-to-end domain suites in certification profile.
- Contract:
  - Verify every requirement ID has at least one test/manual verification reference.
- End-to-end:
  - Full certification dry-run pipeline including artifact packaging.
- Load/failure:
  - Stress test selected launch/service flows for stability evidence.

## 10. Documentation Strategy
- ExDoc requirements:
  - Certification gate enforces `@moduledoc`/`@doc`/`@spec` coverage for all public modules/functions.
  - Public API examples must be present for top-level Tool/Platform and service entry points.
- Supporting docs:
  - Required docs sets (integration guides, migration guides, troubleshooting, compatibility matrix) must exist under `docs/`.
- Verification:
  - Certification profile includes `mix docs` and documentation completeness checks as gating steps.

## 11. Decisions
1. Primary LMS certification evidence targets:
Decision: Canvas and Moodle.
Implementation impact: certification scripts, compatibility matrix entries, and manual QA evidence collection must prioritize Canvas and Moodle environments.

2. Certification profile scheduling:
Decision: Run certification profiles on release branches only.
Implementation impact: CI configuration will gate release branches with certification jobs; nightly scheduled runs are out of scope for this feature set.
