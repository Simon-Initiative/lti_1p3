# Architecture

## System Map

`lti_1p3` is an Elixir library that exposes two main integration surfaces:

- Tool-side modules under `Lti_1p3.Tool` for registration, deployment, OIDC login, launch validation, and service calls such as AGS and NRPS.
- Platform-side modules under `Lti_1p3.Platform` for platform instance management, login hints, and authorization redirect flow.

Shared concerns live in the root `Lti_1p3` namespace and supporting modules:

- Claim parsing modules under `lib/lti_1p3/claims/` normalize LTI claim payloads.
- Role helpers under `lib/lti_1p3/roles/` encapsulate role parsing and semantics.
- `Lti_1p3.DataProvider` defines the persistence boundary. The default configured provider in test is the in-memory provider, but the library is intended to support durable custom providers.
- `Lti_1p3.KeyProvider` and the key provider supervisor manage remote platform JWK fetching, caching, and refresh behavior for JWT verification.
- `Lti_1p3.KeyGenerator`, `Lti_1p3.Jwk`, `Lti_1p3.Nonce`, and related modules handle key material, public key exposure, and replay protection primitives.

The repository is documentation-heavy because many consumers integrate the library into Phoenix or other Elixir applications. The library itself does not own application routes, controllers, HTML, or persistent storage; those are expected to be supplied by integrators.

## Major Boundaries

- Public package API: `Lti_1p3`, `Lti_1p3.Tool`, and `Lti_1p3.Platform`.
- Persistence boundary: custom data providers and registrations/deployments storage are outside the library core.
- Runtime integration boundary: application supervision trees must add the key provider supervisor when using version `1.0+`.
- Network boundary: outbound HTTP is used for remote JWK retrieval and service APIs; tests replace HTTP with a mock client.
