# Implementation Plan

## Phase 0 - Certification Framework Definition
### Deliverables
- Certification framework baseline and requirement ID catalog.

### Tasks
- [ ] Define requirement ID taxonomy for core/AGS/NRPS/deep-linking/security.
- [ ] Create conformance matrix template and evidence model.
- [ ] Define certification candidate release gate policy.
- [ ] Define documentation gate policy requiring full ExDoc coverage and required guides under `docs/`.

### Verification
- [ ] Framework and gate policy approved.
- [ ] Requirement ID catalog published.

## Phase 1 - Conformance Mapping and Suite Structuring
### Deliverables
- Requirement-to-test mappings and reorganized test suites.

### Tasks
- [ ] Map existing tests to requirement IDs and identify coverage gaps.
- [ ] Create `test/conformance` structure by domain.
- [ ] Add metadata/tag conventions to enforce requirement linkage.
- [ ] Fill high-priority automated test gaps blocking certification.
- [ ] Map all public modules/APIs to documentation coverage checks and required guides.

### Verification
- [ ] All in-scope requirements mapped or flagged with owner/date.
- [ ] Conformance suites run locally and in CI.

## Phase 2 - Manual QA and Interop Artifacts
### Deliverables
- Manual certification scripts and reproducible evidence templates.

### Tasks
- [ ] Author manual QA scripts per domain and negative security scenarios.
- [ ] Create evidence capture templates for sandbox runs.
- [ ] Build LMS compatibility matrix and known deviations log.

### Verification
- [ ] Manual scripts reviewed and dry-run completed.
- [ ] Compatibility matrix published.

## Phase 3 - CI Certification Profile and Dossier
### Deliverables
- Automated certification profile and report artifacts.

### Tasks
- [ ] Implement CI certification job with conformance suites + coverage.
- [ ] Generate machine-readable and human-readable run summaries.
- [ ] Add certification dossier template with links to artifacts and architecture/security notes.
- [ ] Add runbook for failed gate triage.
- [ ] Run `mix docs` and documentation completeness checks as part of certification CI gate.

### Verification
- [ ] Certification CI profile passes on candidate branch.
- [ ] Dossier template complete and reproducible.
- [ ] Certification profile fails if any public API docs or required `docs/` guides are missing.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- End-to-end certification readiness sign-off report.

### Tasks
- [ ] Execute full manual QA scripts against target LMS sandboxes.
- [ ] Execute full certification CI profile on release-candidate build.
- [ ] Review unresolved defects against gate policy.
- [ ] Produce final readiness decision document.

### Verification
- [ ] Sign-off report approved by maintainers.
- [ ] Go/No-Go decision recorded with evidence links.

## PR Grouping
- PR Group 1: Phases 0-1
- PR Group 2: Phase 2
- PR Group 3: Phases 3-4
