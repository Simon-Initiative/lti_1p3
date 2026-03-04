# Product Requirements Document

## 1. Feature Summary
- Name: LTI 1.3 Certification Program Readiness
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-03
- Status: Proposed

## 2. Problem Statement
- Current pain: The library has substantial functionality but lacks a formalized conformance program, traceable requirement mapping, and certification execution readiness.
- Why now: Project goal is full LTI 1.3 + services support and eventual external certification.

### Current State Analysis
- Existing tests are strong in selected areas but are not organized as a certification-oriented conformance suite.
- No single source-of-truth matrix maps spec clauses to implementation and automated/manual evidence.
- API inconsistencies and partial service implementations currently block a clean certification narrative.
- Operational artifacts (runbooks, compatibility matrix, release gates) are not yet structured for certification cycles.

## 3. Goals and Non-Goals
### Goals
- Establish certification-grade conformance program across core, AGS, NRPS, and Deep Linking.
- Deliver deterministic test harnesses, manual scripts, and evidence capture templates.
- Define release gates and quality bars for “certification candidate” builds.
- Ensure documentation provides integrator-ready, simple API examples for tool and platform roles.
- Enforce documentation quality gates: all public modules/APIs documented for ExDoc and all supporting guides maintained under `docs/`.

### Non-Goals
- Completing third-party certification submission itself in this feature.
- Owning LMS vendor support SLAs.

## 4. Users and Primary Use Cases
- Personas: Library maintainers preparing certification; QA engineers executing conformance tests; integrators evaluating readiness.
- Core scenarios:
  - Maintainer runs full conformance suite and receives pass/fail with traceability.
  - QA executes manual interoperability scripts against LMS sandboxes.
  - Release manager checks certification gate criteria before publishing.

## 5. Functional Requirements
1. Create full conformance matrix mapping spec requirements to tests and evidence.
2. Build automated certification test suite structure by domain (core/AGS/NRPS/deep-linking).
3. Add manual certification scripts and result capture templates.
4. Define and implement certification readiness CI job/profile.
5. Define release gate policy (coverage, pass rate, critical defect threshold, docs completeness).
6. Publish compatibility matrix for tested LMS versions and known deviations.
7. Produce certification dossier template including architecture/security notes and test evidence links.
8. Add onboarding docs for running certification workflows locally and in CI.
9. Add a documentation conformance matrix that maps each public module/API to ExDoc coverage and guide references.

## 6. Non-Functional Requirements
- Reliability: Certification suite runs deterministically with stable fixtures.
- Performance: Full certification profile execution time target under agreed CI budget.
- Security/Compliance: Security-sensitive negative tests required (signature, nonce replay, scope misuse).
- Observability: CI artifacts include machine-readable results and human-readable summary.
- Documentation: Certification-candidate builds fail if ExDoc coverage or required guides under `docs/` are incomplete.

## 7. Success Metrics
- Product metrics:
  - 100% mapped requirements for core + AGS + NRPS + Deep Linking.
  - Certification-candidate release checklist completed for target version.
- Technical metrics:
  - Conformance suite pass rate 100% for gating branch.
  - Manual QA script completion with documented evidence for all required scenarios.

## 8. Dependencies and Constraints
- Internal dependencies: Completion of core, AGS, NRPS, deep-linking feature sets.
- External dependencies: LMS sandbox availability and 1EdTech certification process details.
- Constraints: Certification evidence must be reproducible across environments.

## 9. Risks and Mitigations
- Risk: Late-found conformance gaps delay certification.
- Mitigation: Incremental conformance gates per domain and early dry runs.
- Risk: Sandbox instability causes flaky evidence.
- Mitigation: Maintain multiple sandbox targets and deterministic local simulators.

## 10. Acceptance Criteria
1. Given the conformance matrix, when reviewed, then every in-scope spec requirement has mapped implementation and verification evidence.
2. Given certification CI profile, when executed, then all domain suites pass and produce archived artifacts.
3. Given manual QA scripts, when run against target LMS sandboxes, then results are recorded and reproducible.
4. Given release candidate build, when evaluated against gate policy, then pass/fail decision is unambiguous.
5. Given integrator docs, when following examples, then tool and platform baseline integrations work without hidden steps.
6. Given documentation gates run, when a public module/API lacks docs or required guides are missing, then certification candidate build fails.
