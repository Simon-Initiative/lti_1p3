# Issue Tracking

## System Of Record

No repository-local issue tracker configuration is defined in the harness contract today. In practice, maintenance work should follow the upstream GitHub repository workflow because CI and package publishing already run through GitHub.

## Intake Workflow

- Reproduce the problem with a focused ExUnit test when possible
- Classify whether the change affects tool flow, platform flow, shared claims/roles, provider boundaries, or docs only
- Record any external compatibility constraints such as LTI spec behavior or Hex package expectations
- Prefer small, reviewable changes that keep docs and tests in sync
