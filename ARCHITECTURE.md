# Architecture

## System Map

`lti_1p3` is a framework-agnostic Elixir library that implements both sides of the LTI 1.3 protocol:

- Shared entry points live in `Lti_1p3` for JWK management, key-cache operations, and common configuration.
- Tool-side flows live under `Lti_1p3.Tool.*` and cover OIDC login redirects, launch validation, message dispatch, and service clients such as AGS and NRPS.
- Platform-side flows live under `Lti_1p3.Platform.*` and cover authorization redirects, login hints, and platform launch payload generation.
- Security-sensitive validation is centralized under `Lti_1p3.Core.Validation.*` for registration, deployment, timestamps, JWTs, nonce checks, and message validation.
- Persistence and integration seams are behavior-driven. Host apps swap in durable implementations via `Lti_1p3.DataProvider` and related provider contracts without changing protocol logic.
- Public key retrieval is managed through the key-provider system (`Lti_1p3.KeyProvider`, `Lti_1p3.KeyProviderSupervisor`, and concrete providers such as `MemoryKeyProvider`).

The library is consumed by Phoenix or other Plug applications, but it does not own HTTP endpoints, browser sessions, or database schema. Those concerns remain in host applications.
