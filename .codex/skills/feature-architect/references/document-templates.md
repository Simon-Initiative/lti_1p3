# Feature Architect Templates

Use these templates as defaults unless the user specifies a different format.

## `prd.md`

```markdown
# Product Requirements Document

## 1. Feature Summary
- Name:
- Owner:
- Last Updated:
- Status:

## 2. Problem Statement
- Current pain:
- Why now:

## 3. Goals and Non-Goals
### Goals
- 

### Non-Goals
- 

## 4. Users and Primary Use Cases
- Personas:
- Core scenarios:

## 5. Functional Requirements
1. 
2. 

## 6. Non-Functional Requirements
- Reliability:
- Performance:
- Security/Compliance:
- Observability:

## 7. Success Metrics
- Product metrics:
- Technical metrics:

## 8. Dependencies and Constraints
- Internal dependencies:
- External dependencies:
- Constraints:

## 9. Risks and Mitigations
- Risk:
- Mitigation:

## 10. Acceptance Criteria
1. Given/When/Then...
2. 
```

## `fdd.md`

```markdown
# Functional Design Document

## 1. Design Overview
- Scope covered:
- Assumptions:

## 2. System Context and Boundaries
- In-scope components:
- Out-of-scope components:

## 3. Architecture
- High-level flow:
- Context/module responsibilities:
- Supervision tree impact:

## 4. Data Design
- Schema changes:
- Data lifecycle:
- Migration/backfill strategy:

## 5. Interfaces and Contracts
- Internal APIs:
- External APIs/webhooks:
- Event/message formats:

## 6. Runtime Behavior
- Process model:
- Concurrency model:
- Failure handling/retries:
- Timeouts/circuit breakers:

## 7. Security and Compliance
- AuthN/AuthZ impact:
- Data protection:
- Audit/logging requirements:

## 8. Observability and Operations
- Metrics:
- Logs:
- Tracing:
- Alerts/runbooks:

## 9. Testing Strategy
- Unit:
- Integration:
- Contract:
- End-to-end:
- Load/failure:

## 10. Open Questions
- 
```

## `plan.md`

```markdown
# Implementation Plan

## Phase 0 - Alignment and Readiness
### Deliverables
- Approved requirements and design baseline

### Tasks
- [ ] Confirm scope, assumptions, and dependencies
- [ ] Finalize acceptance criteria and test approach
- [ ] Identify rollout and rollback constraints

### Verification
- [ ] PRD and FDD approved
- [ ] Risks have owners and mitigations

## Phase 1 - Foundations
### Deliverables
- Core scaffolding and contracts

### Tasks
- [ ] Implement core domain modules/contexts
- [ ] Add schema changes and safe migrations
- [ ] Establish feature flags/config and baseline telemetry

### Verification
- [ ] Unit tests for core modules pass
- [ ] Migrations verified in staging-like environment

## Phase 2 - Feature Implementation
### Deliverables
- End-to-end feature behavior

### Tasks
- [ ] Implement business workflows and process interactions
- [ ] Implement external/internal interfaces
- [ ] Add error handling, retry logic, and idempotency protections

### Verification
- [ ] Integration tests pass
- [ ] Failure-path behavior verified

## Phase 3 - Hardening and Launch
### Deliverables
- Production readiness and release

### Tasks
- [ ] Add dashboards, alerts, and runbook updates
- [ ] Execute load/performance and security checks
- [ ] Run staged rollout and monitor key metrics

### Verification
- [ ] SLO/SLA criteria met
- [ ] Rollback procedure validated
- [ ] Launch sign-off recorded
```

## Task Authoring Rules

- Write each task as one actionable unit of work.
- Keep tasks independently checkable.
- Add explicit verification checkboxes per phase.
- Do not mark tasks complete unless the user provides completion status.
