# Operations

## Observability

This repository is a library, so it does not own production telemetry pipelines or dashboards. Observability is mainly:

- CI signal from GitHub Actions build and test workflows
- Coverage reporting through Coveralls
- Consumer-application logs emitted through the standard Elixir logger

Changes that affect runtime behavior should preserve useful error tuples and logger compatibility for downstream applications.

## Performance

Performance-sensitive paths are concentrated around:

- JWT validation during launch flow
- JWK retrieval, caching, and refresh behavior
- AGS and NRPS service request handling

Prefer avoiding repeated network fetches, unnecessary JSON re-parsing, and regressions in hot-path validation code. Key provider cache behavior is a primary performance lever in this codebase.

## Rollout

Releases are package-oriented rather than service-oriented:

- CI validates pushes and pull requests on `master`
- Hex publishing is triggered by version tags matching the publish workflow
- Library changes that alter integration setup must update `README.md` and related docs before release
- There is no runtime rollout plan in this repository; consumer applications own deployment and migration sequencing
