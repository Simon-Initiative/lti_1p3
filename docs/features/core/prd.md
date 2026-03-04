# Product Requirements Document

## 1. Feature Summary
- Name: LTI 1.3 Core Completion and API Unification
- Owner: Lti_1p3 Maintainers
- Last Updated: 2026-03-03
- Status: Proposed

## 2. Problem Statement
- Current pain: The library has strong baseline support but core LTI 1.3 behavior is incomplete and API ergonomics are inconsistent for tool/platform consumers.
- Why now: AGS/NRPS/Deep Linking completion and certification require a stable, spec-correct core and a cohesive functional API.

### Current State Analysis
- Launch message validation currently targets only `LtiResourceLinkRequest` (`lib/lti_1p3/tool/message_vaildators/resource_message_validator.ex`).
- Directory/module naming has inconsistencies (`message_vaildators` typo) that leak into maintainability and discoverability.
- Public API is uneven across domains: `Lti_1p3.Platform` exposes only platform instance creation while launch helpers live in nested modules.
- Provider contract return shapes are inconsistent in implementations (for example `get_jwk_by_registration` behavior contract vs memory provider return).
- Utility validation has correctness risk (`validate_audience/2` logic in `lib/lti_1p3/utils.ex`).
- In-memory provider uses `use GenServer` but runtime behavior is `Agent`, indicating architectural drift (`lib/lti_1p3/data_providers/memory_provider.ex`).

## 3. Goals and Non-Goals
### Goals
- Deliver complete LTI 1.3 core launch correctness for tool and platform flows.
- Provide a simple, coherent functional API with consistent tuple return contracts.
- Standardize validation pipeline outputs and reason atoms for predictable integration.
- Refactor internal architecture for maintainability without framework coupling.
- Treat documentation as a first-class deliverable for every public module and API.

### Non-Goals
- Maintaining backward compatibility with existing API names or tuple shapes.
- Implementing AGS/NRPS/Deep Linking protocol details beyond core hooks (covered by separate features).
- Building opinionated Phoenix generators or UI workflows.

## 4. Users and Primary Use Cases
- Personas: Elixir engineers building LTI tools; Elixir engineers building LMS/platforms; maintainers integrating provider adapters.
- Core scenarios:
  - Tool app validates OIDC login + launch and consumes normalized claims.
  - Platform app validates auth request and emits signed id_token with required claims.
  - Integrators manage registrations, deployments, platform instances, and key lifecycle through one consistent API surface.

## 5. Functional Requirements
1. Expose unified top-level domain APIs for tool and platform core flows.
2. Validate all required OIDC and LTI core claims with explicit reasoned failures.
3. Support both resource link and deep linking launch message validation dispatch (response handling in Deep Linking feature).
4. Normalize registration/deployment/platform instance CRUD contracts and error map shape.
5. Standardize provider behavior return contracts and enforce via tests.
6. Harden JWT validation (kid resolution, signature algorithm constraints, issuer/audience/time/nonce checks).
7. Provide claim normalization helpers that map raw claims into typed structs.
8. Emit telemetry events for core validation success/failure and key retrieval behavior.
9. Document all public modules/functions with `@moduledoc`, `@doc`, and accurate `@spec`, plus runnable examples where practical.
10. Add and maintain integration guides under `docs/` for tool, platform, migration, and troubleshooting workflows.

## 6. Non-Functional Requirements
- Reliability: Core launch validation failure rate attributable to library defects < 0.1% in certification harness runs.
- Performance: P95 launch validation (excluding remote key fetch latency) < 50ms in local benchmark with warm key cache.
- Security/Compliance: No acceptance of invalid signature/audience/issuer/deployment/nonce; key material handling must never expose private keys.
- Observability: Structured logs + telemetry events for each validation stage and final outcome.
- Documentation: 100% of public API surface is ExDoc-documented and all supporting guides are versioned under `docs/`.

## 7. Success Metrics
- Product metrics:
  - 100% pass for defined core conformance test matrix.
  - New API adoption examples for both tool and platform paths in docs.
- Technical metrics:
  - >= 95% test coverage for core validation modules.
  - Zero inconsistent provider return-shape violations in contract tests.

## 8. Dependencies and Constraints
- Internal dependencies: Provider behaviors, key provider system, claims modules, launch/auth modules.
- External dependencies: JOSE/Joken correctness, HTTP client behavior for JWK fetch.
- Constraints: Must remain framework-agnostic and support pluggable persistence.

## 9. Risks and Mitigations
- Risk: API redesign introduces migration friction.
- Mitigation: Publish migration guide and deprecation bridge shim during rollout period.
- Risk: Security regressions during refactor.
- Mitigation: Add negative-path security regression suite and property tests for claim/time validation.
- Risk: Provider ecosystem incompatibility.
- Mitigation: Add behavior conformance tests that external adapters can reuse.

## 10. Acceptance Criteria
1. Given a valid tool launch request, when `Tool.launch_validate/2` is called, then it returns `{:ok, %Launch{}}` with normalized claims.
2. Given invalid issuer/audience/signature/timestamps/nonce/state/deployment, when validated, then it returns `{:error, %{reason: reason_atom, stage: stage_atom, ...}}` with deterministic reason atoms.
3. Given a valid platform authorization request, when `Platform.authorize_redirect/4` is called, then it returns signed id_token + redirect metadata.
4. Given provider implementations, when contract tests are executed, then all behavior callback shapes and invariants pass.
5. Given telemetry is enabled, when launches are validated, then stage-level and outcome-level events are emitted with correlation metadata.
6. Given `mix docs` runs, when documentation is generated, then all public modules/APIs have complete docs/specs and referenced guides exist under `docs/`.
