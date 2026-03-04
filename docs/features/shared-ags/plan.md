# Implementation Plan

## Phase 0 - Shared Contract Definition
### Deliverables
- Shared AGS reason/scope/telemetry contract definitions.

### Tasks
- [ ] Define AGS reason atom catalog and error shape contract.
- [ ] Define AGS operation-to-scope mapping catalog.
- [ ] Define AGS telemetry event/metadata contract.
- [ ] Define shared compatibility policy interface.

### Verification
- [ ] Shared contract review approved by tool/platform owners.

## Phase 1 - Shared Module Implementation
### Deliverables
- Shared AGS modules and constants.

### Tasks
- [ ] Implement shared error helpers and reason constants.
- [ ] Implement shared scope catalog helpers.
- [ ] Implement shared telemetry naming helpers.
- [ ] Implement shared compatibility policy defaults.

### Verification
- [ ] Unit tests pass for all shared modules.

## Phase 2 - Conformance and Integration
### Deliverables
- Reusable contract tests and role-track integration.

### Tasks
- [ ] Add reusable AGS contract test helpers.
- [ ] Integrate shared modules into tool AGS track.
- [ ] Integrate shared modules into platform AGS track.
- [ ] Resolve naming and migration issues.

### Verification
- [ ] Contract tests pass in both role tracks.
- [ ] No divergent reason/scope/telemetry naming remains.

## Phase 3 - Documentation and Migration
### Deliverables
- Shared AGS contract docs and migration guidance.

### Tasks
- [ ] Publish shared AGS contract reference docs.
- [ ] Update tool/platform AGS docs to reference shared contracts.
- [ ] Add migration guidance for prior AGS contract usage.
- [ ] Ensure ExDoc coverage for shared modules.

### Verification
- [ ] `mix docs` completes and references resolve.
- [ ] Migration notes reviewed.

## Phase 4 - Manual QA Acceptance Testing
### Deliverables
- Manual verification report for shared AGS contract adoption.

### Tasks
- [ ] Verify tool and platform AGS telemetry parity in sample flows.
- [ ] Verify shared error reasons in representative failures.
- [ ] Verify scope mapping equivalence across role tracks.
- [ ] Record findings and remediation owners.

### Verification
- [ ] Manual QA report approved.
