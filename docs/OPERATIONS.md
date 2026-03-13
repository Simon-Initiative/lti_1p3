# Operations

## Observability

- The library emits `:telemetry` events for core validation stages and outcomes. See `docs/telemetry.md` for event names, measurements, and metadata.
- The library also logs validation summaries through `Logger`; consuming applications control log routing and verbosity.
- There is no built-in metrics backend or tracing exporter in this repository. Observability is delegated to host applications.

## Performance

- The main runtime performance considerations are JWT validation, outbound key retrieval, and cache-hit behavior in the key-provider subsystem.
- `Lti_1p3.KeyProviderSupervisor` and cache-management APIs exist to reduce repeated key fetches and support refresh workflows.
- Performance-sensitive changes should avoid adding unnecessary network requests or repeated cryptographic work inside validation paths.

## Rollout

- This repository is published as a library rather than rolled out as a standalone service.
- Release readiness means maintaining backward-compatible public APIs, documenting migration steps in `docs/migrations/` when needed, and updating `CHANGELOG.md`.
- Host applications are responsible for deploying any surrounding web endpoints, supervision trees, and durable provider implementations.
