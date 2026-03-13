# Issue Tracking

## System Of Record

- No repository-local issue tracker is configured in the harness contract today.
- Until a formal tracker is documented, the practical system of record is the repository history plus active execution plans under `docs/exec-plans/current/` and archived feature work under `docs/exec-plans/archive/features/`.

## Intake Workflow

- Capture new feature work as a scoped work item with `prd.md`, `fdd.md`, and `plan.md` under the appropriate docs directory.
- Capture bugs with enough protocol context to reproduce them: issuer, client ID, deployment, message type, failing validation stage, and expected reason atom or return shape.
- Before implementation, identify whether the change touches Tool flows, Platform flows, shared security, or provider contracts so testing and docs updates are scoped correctly.
