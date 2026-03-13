# Functional Design Document

## 1. Design Overview

- Scope covered: Core tool/platform LTI 1.3 launch flows, API unification, provider contract alignment, and security hardening.
- Assumptions:
  - Backward compatibility can be broken in favor of clean API.
  - Existing provider adapters can be updated to match new behavior contracts.

## 2. System Context and Boundaries

- In-scope components:
  - `Lti_1p3.Tool` and `Lti_1p3.Platform` top-level APIs.
  - Launch/auth validation pipelines.
  - Provider behavior contracts and in-memory provider reference implementation.
  - Key provider integration points and telemetry.
- Out-of-scope components:
  - AGS/NRPS/Deep Linking service-specific protocol operations.
  - Framework-specific controllers/views.

## 3. Architecture

- High-level flow:
  - Tool: `login_request_validate -> auth_redirect_build -> launch_validate -> normalized_launch`.
  - Platform: `auth_request_validate -> claim_assembly -> id_token_sign -> redirect_payload`.
- Context/module responsibilities:
  - `Lti_1p3.Tool`: public functional API for tool-side operations.
  - `Lti_1p3.Platform`: public functional API for platform-side operations.
  - `Lti_1p3.Core.Validation`: shared validators (state, issuer, audience, timestamps, nonce, deployment).
  - `Lti_1p3.Core.Claims`: claim extraction, normalization, typed structs.
  - `Lti_1p3.Core.Errors`: canonical error map builders and reason atoms.
  - `Lti_1p3.ProviderContracts`: conformance helpers for behavior implementations.
- Supervision tree impact:
  - Keep key provider under `Lti_1p3.KeyProviderSupervisor`.
  - Convert in-memory data provider to either pure Agent module or proper GenServer (choose one, document rationale).

## 4. Data Design

- Schema changes:
  - No required DB schema in library core; behavior contracts may require additional metadata fields in adapter stores.
- Data lifecycle:
  - Nonce/login_hint entries remain TTL-bound and cleanup-capable.
  - Launch validation does not persist launch payload by default.
- Migration/backfill strategy:
  - Provide adapter migration guide for updated behavior callback signatures and error shapes.

## 5. Interfaces and Contracts

- Internal APIs:
  - `Lti_1p3.Tool.login_redirect(params, opts)` -> `{:ok, %{state: ..., redirect_url: ...}} | {:error, error}`
  - `Lti_1p3.Tool.validate_launch(params, expected_state, opts)` -> `{:ok, %Tool.Launch{}} | {:error, error}`
  - `Lti_1p3.Platform.authorize_redirect(params, current_user, issuer, claims, opts)` -> `{:ok, payload} | {:error, error}`
- External APIs/webhooks:
  - No direct HTTP endpoints; consumer app owns transport.
- Event/message formats:
  - Canonical error map: `%{reason: atom(), stage: atom(), msg: String.t(), details: map()}`

## 6. Runtime Behavior

- Process model:
  - Core validation remains mostly stateless functional modules.
  - Key provider remains stateful supervised process.
- Concurrency model:
  - Key fetch cache handles concurrent reads; validation functions are pure and process-safe.
- Failure handling/retries:
  - JWT key fetch retries bounded and explicit via key provider.
  - Launch validation fails fast with stage-specific reason maps.
- Timeouts/circuit breakers:
  - Add configurable HTTP timeout for key retrieval; fail closed on timeout.

## 7. Security and Compliance

- AuthN/AuthZ impact:
  - Enforce issuer/audience/state/nonce/deployment constraints across tool and platform flows.
- Data protection:
  - Never expose private key material in public API; sanitize logs.
- Audit/logging requirements:
  - Log reason atoms and stage, exclude sensitive token content.

## 8. Observability and Operations

- Metrics:
  - `launch_validation.duration`, `launch_validation.failure_count`, `key_provider.cache_hit_rate`.
- Logs:
  - Structured stage-level logs with correlation id.
- Tracing:
  - Telemetry spans around key retrieval and validation stages.
- Alerts/runbooks:
  - Alert on elevated invalid-signature failures and key fetch failure spikes.

## 9. Testing Strategy

- Unit:
  - Validation modules, error mapping, claim normalization, audience/time checks.
- Integration:
  - End-to-end tool launch and platform authorization with mocked key endpoints.
- Contract:
  - Shared provider behavior conformance tests for all callbacks.
- End-to-end:
  - Plug/Phoenix sample integration tests proving framework-agnostic wiring.
- Load/failure:
  - High-volume launch validation with stale/rotating keys and nonce duplication attempts.

## 10. Documentation Strategy

- ExDoc requirements:
  - Every public module must include `@moduledoc`.
  - Every public function must include `@doc` and accurate `@spec`.
  - Public APIs should include concise examples where practical.
- Supporting docs:
  - Maintain core integration, migration, and troubleshooting guides under `docs/`.
- Verification:
  - `mix docs` runs in CI for this feature and docs completeness is a release gate.

## 11. Decisions

1. API output shape for claims:
Decision: Default to typed structs, with optional raw-claim passthrough.
Implementation impact: core launch/auth APIs should return typed domain structs by default and support an explicit option (for example `raw_claims: true`) to include raw claim maps for advanced integrations.

2. Provider conformance test packaging:
Decision: No helper macros for third-party adapter libraries.
Implementation impact: provider contract tests remain internal to this repository; external adapters may use documentation-based conformance guidance rather than shipped macro tooling.
