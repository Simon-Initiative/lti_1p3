# Core Tool API Modernization - Functional Design Document

## 1. Executive Summary
This work item makes `Lti_1p3.Tool` the canonical Tool-side entry point for registration, deployment, OIDC login initiation, and launch validation. The design adds a thin orchestration layer and explicit request/result structs on top of the existing provider, key, nonce, and claim-validation modules so consumers can implement the core Tool flow through one public surface with consistent success and error tuples. Existing lower-level modules remain available for compatibility, but documentation and future Tool features should build on the new top-level contracts. This design satisfies `FR-001` through `FR-006` and directly targets `AC-001` through `AC-009`.

## 2. Requirements & Assumptions
- Functional requirements:
  - `FR-001`, `FR-002`, and `FR-003` require one cohesive Tool API for registration/deployment management, OIDC login initiation, and launch validation.
  - `FR-004` requires standardized success and error shapes across the Tool core flow.
  - `FR-006` requires coverage and docs updates for the supported Tool path.
- Non-functional requirements:
  - `FR-005` and `AC-006` require provider-backed storage boundaries to remain unchanged.
  - `AC-002` requires login initiation to validate issuer, client, and login inputs with explicit tuples.
  - `AC-003` and `AC-007` require pure-data inputs and outputs with no Plug or Phoenix structs in the library API.
  - `AC-004` requires launch validation to cover token, registration, deployment, nonce, state, and required claims with explicit tuples.
  - `AC-005` requires the documented success and error contract to stay consistent across registration, login, and launch.
  - `AC-008` requires security-sensitive negative-path automation, not only happy-path coverage.
  - Security-sensitive validation around registration lookup, deployment lookup, JWT verification, nonce handling, and OIDC state must remain explicit and testable.
  - README and package docs are part of the product surface and must present the new flow as canonical.
- Assumptions:
  - The configured `Lti_1p3.DataProvider` and key provider boundaries remain the durable extension points for this repository.
  - Consumer applications continue to own browser redirects, session persistence, and route/controller wiring.
  - Service modules such as AGS and NRPS will consume launch context produced by the new Tool API rather than bypass it.
  - Backward compatibility should prefer additive changes and staged de-emphasis of older module entry points over immediate removal.

## 3. Repository Context Summary
- What we know:
  - `lib/lti_1p3/tool.ex` currently fronts only registration and deployment persistence operations.
  - `lib/lti_1p3/tool/oidc_login.ex` and `lib/lti_1p3/tool/launch_validation.ex` own core login and launch behavior but expose different tuple shapes and parameter expectations.
  - `lib/lti_1p3/data_provider.ex` defines Tool provider callbacks that return a mix of tuples, structs, `nil`, and `{nil, nil}` values.
  - `ARCHITECTURE.md`, `docs/BACKEND.md`, and `docs/FRONTEND.md` prohibit first-party web and storage ownership.
  - `docs/OPERATIONS.md` expects explicit error tuples and logger-compatible failures rather than repo-owned telemetry pipelines.
  - Existing tests strongly cover launch validation failures, while README examples still direct consumers into secondary modules.
- Unknowns to confirm:
  - Whether any external consumers depend on undocumented tuple details from `Lti_1p3.Tool.OidcLogin` and `Lti_1p3.Tool.LaunchValidation`.
  - Whether the maintainers want immediate deprecation warnings on secondary modules or documentation-only de-emphasis in this slice.

## 4. Proposed Design
### 4.1 Component Roles & Interactions
Introduce `Lti_1p3.Tool` as the stable orchestration facade for the core Tool lifecycle:

- Registration and deployment APIs remain on `Lti_1p3.Tool`, but lookup functions move to normalized tuple-based contracts.
- Add top-level login and launch functions on `Lti_1p3.Tool`, backed internally by dedicated request/result modules and the existing validation primitives.
- Keep `Lti_1p3.Tool.OidcLogin` and `Lti_1p3.Tool.LaunchValidation` as implementation-facing modules or compatibility shims. They may delegate into the new `Lti_1p3.Tool` functions to prevent duplicated validation paths.
- Reuse current provider callbacks for registration, deployment, and JWK lookup.
- Reuse the key provider and nonce validation flow in launch validation. No new storage or supervision concerns are introduced.

The design favors a thin orchestration layer instead of refactoring the full validation stack. That is the simplest change that unifies the public API without destabilizing the security-critical logic already covered by tests.

### 4.2 State & Data Flow
Registration and deployment flow:

1. Consumer builds `%Lti_1p3.Tool.Registration{}` or `%Lti_1p3.Tool.Deployment{}`.
2. `Lti_1p3.Tool` delegates persistence to the configured data provider.
3. API returns normalized tuples such as `{:ok, registration}` or `{:error, error_map}` while preserving provider-backed persistence semantics.

OIDC login flow:

1. Consumer passes a pure-data login request struct or map containing `iss`, `client_id`, `login_hint`, `target_link_uri`, and optional LTI hints.
2. `Lti_1p3.Tool.initiate_login/1` validates required fields, resolves the registration through the provider, and constructs a login result with generated `state`, generated `nonce`, redirect parameters, and final `redirect_url`.
3. Consumer persists `state` using its own session or storage approach and performs the browser redirect outside the library.

This flow is the primary design answer for `AC-002` and `AC-003`.

Launch validation flow:

1. Consumer passes launch params and application-owned state material to `Lti_1p3.Tool.validate_launch/2`.
2. The top-level function validates OIDC state, extracts and verifies the ID token, resolves registration and deployment through provider boundaries, validates timestamps, message type, required claims, and nonce, then normalizes the result into a `LaunchContext`.
3. The returned launch context exposes the normalized claims plus the resolved registration and deployment so downstream Tool services have a stable handoff object.

This flow is the primary design answer for `AC-004`.

### 4.3 Lifecycle & Ownership
- `Lti_1p3.Tool` owns public API naming, tuple normalization, and high-level request/result contracts.
- Existing lower-level Tool modules own reusable validation internals until or unless a later refactor collapses them.
- `Lti_1p3.DataProvider` implementations continue to own registration, deployment, nonce, and JWK persistence.
- Consumer applications own:
  - route/controller wiring
  - session or other persistence for OIDC `state`
  - browser redirects and HTTP responses
  - any application logging or telemetry built from returned error tuples

### 4.4 Alternatives Considered
- Keep the current split public API and only update docs:
  - Rejected because it does not satisfy `FR-001` through `FR-004`; the core inconsistency is structural, not just documentary.
- Fully replace lower-level modules and provider callback shapes in one slice:
  - Rejected because it creates avoidable compatibility and migration risk in security-sensitive code.
- Add only wrapper functions returning raw claims:
  - Rejected because it misses the need for a stable launch handoff object for later AGS, NRPS, and Deep Linking work.

## 5. Interfaces
- `Lti_1p3.Tool.create_registration(%Lti_1p3.Tool.Registration{}) :: {:ok, Registration.t()} | {:error, term()}`
  - Existing API remains, with docs updated to treat it as part of the canonical flow.
- `Lti_1p3.Tool.create_deployment(%Lti_1p3.Tool.Deployment{}) :: {:ok, Deployment.t()} | {:error, term()}`
  - Existing API remains canonical for deployment creation.
- `Lti_1p3.Tool.get_registration(issuer, client_id) :: {:ok, Registration.t()} | {:error, error_map}`
  - New normalized lookup wrapper over provider `get_registration_by_issuer_client_id/2`.
- `Lti_1p3.Tool.get_registration_deployment(issuer, client_id, deployment_id) :: {:ok, %{registration: Registration.t(), deployment: Deployment.t()}} | {:error, error_map}`
  - New normalized tuple contract replaces the mixed struct/`nil` shape at the top-level API.
- `Lti_1p3.Tool.initiate_login(login_request) :: {:ok, LoginResult.t()} | {:error, error_map}`
  - `login_request` is a pure-data struct or map containing required OIDC login fields.
  - `LoginResult` contains at minimum `state`, `nonce`, `redirect_params`, `redirect_url`, and `registration`.
- `Lti_1p3.Tool.validate_launch(launch_request, expected_state) :: {:ok, LaunchContext.t()} | {:error, error_map}`
  - `launch_request` accepts pure request params, with `expected_state` passed separately or inside a validation struct.
  - `LaunchContext` contains `claims`, `registration`, `deployment`, and raw launch params needed by downstream services.

Common error contract:

- All new top-level Tool errors return `{:error, %{reason: atom(), msg: String.t()} = error}` with contextual keys when available.
- Top-level reasons are standardized across the flow: `:missing_param`, `:invalid_registration`, `:invalid_deployment`, `:invalid_oidc_state`, `:token_malformed`, `:invalid_message_type`, `:invalid_message`, `:invalid_nonce`, and provider-specific persistence failures mapped without losing detail.
- Compatibility modules may preserve legacy exact tuple payloads internally, but the documented top-level API uses the normalized contract.

This contract is the primary design answer for `AC-005`.

## 6. Data Model & Storage
- No provider schema or callback changes are required in this slice.
- New public structs are library-only value objects, not persisted records:
  - `Lti_1p3.Tool.LoginRequest`
  - `Lti_1p3.Tool.LoginResult`
  - `Lti_1p3.Tool.LaunchRequest` or equivalent top-level validation input
  - `Lti_1p3.Tool.LaunchContext`
- Existing persisted records remain:
  - `Lti_1p3.Tool.Registration`
  - `Lti_1p3.Tool.Deployment`
  - nonce and JWK records via existing shared boundaries
- OIDC `state` remains consumer-owned transient state. The library generates it but does not persist it.
- Nonce persistence remains on the existing nonce provider path used during launch validation.

## 7. Consistency & Transactions
- Registration and deployment creation continue to be independent provider operations with no new cross-record transaction boundary.
- Login initiation is side-effect free inside the library except for random value generation. It does not write state to provider storage.
- Launch validation continues to rely on explicit step ordering:
  - state validation before launch processing
  - registration resolution before key lookup
  - JWT verification before deployment and message validation
  - nonce validation after token validation
- Because the repository is storage agnostic, no new transactional guarantees are added beyond existing provider semantics.

## 8. Caching Strategy
- Reuse the existing key provider cache for remote platform JWK retrieval.
- The new top-level Tool API does not add additional caching layers.
- `LaunchContext` should carry already-resolved registration and deployment data so downstream Tool service calls do not need to repeat those lookups within the same request lifecycle.

## 9. Performance & Scalability Posture
- The design keeps the hot path unchanged for JWT verification and JWK retrieval, which avoids introducing new performance regressions in the most sensitive path.
- Value-object normalization adds negligible overhead compared with JWT parsing and signature verification.
- Passing resolved registration and deployment data forward in `LaunchContext` reduces redundant provider reads in later Tool service features.
- Validation should avoid repeated parsing of `id_token` claims once the verified claims body is available.

## 10. Failure Modes & Resilience
- Missing login parameters:
  - Return `{:error, %{reason: :missing_param, ...}}` with the missing field called out explicitly.
- Unknown registration during login or launch:
  - Return `{:error, %{reason: :invalid_registration, issuer: ..., client_id: ...}}`.
- Unknown deployment during launch:
  - Return `{:error, %{reason: :invalid_deployment, registration_id: ..., deployment_id: ...}}`.
- Missing or mismatched OIDC state:
  - Return `{:error, %{reason: :invalid_oidc_state, ...}}` without attempting token validation.
- Malformed or invalid JWT:
  - Return explicit signature or token-shape failures surfaced through the normalized contract.
- Unsupported or invalid LTI message payload:
  - Return `:invalid_message_type` or `:invalid_message` with enough context for downstream logging.
- Nonce replay or invalid nonce:
  - Preserve explicit launch failure behavior and keep negative-path coverage mandatory.
- Provider failures:
  - Pass through actionable provider context rather than collapsing failures into generic errors.

## 11. Observability
- No first-party telemetry events are added in this slice because the repository does not own a telemetry pipeline.
- Standardized top-level error tuples are the primary observability contract for consumer applications and align with `docs/OPERATIONS.md`.
- Documentation should call out which error reasons are expected during registration setup, login failures, and launch validation so downstream logging remains actionable.
- Code review should explicitly verify that docs, examples, and public types reflect the implemented tuple shapes.
- Issue tracking follow-up should use the existing GitHub-centered workflow if external compatibility regressions are found after release.

## 12. Security & Privacy
- Maintain current security ordering for launch validation: state, token extraction, signature verification, timestamps, deployment, message validation, and nonce checks.
- Do not move OIDC state into library-managed process state or session abstractions.
- Do not widen provider responsibilities or expose private key material through the new Tool API.
- Keep launch request and login APIs free of framework-specific request objects so there is no hidden coupling to host application session or conn state.
- Backward compatibility shims must delegate into the same validation path as the new top-level API to avoid divergent security behavior.

## 13. Testing Strategy
- Add or update unit and integration-style tests for:
  - top-level registration and deployment wrappers
  - top-level login initiation happy path and missing/invalid parameter failures
  - top-level launch validation happy path and negative security-sensitive failures
  - normalized tuple shapes for registration lookup, deployment lookup, login, and launch
  - compatibility coverage showing legacy modules delegate correctly if preserved
- The automated coverage changes in this section are the primary design answer for `AC-008`.
- Verification gates:
  - `mix compile --warnings-as-errors`
  - `mix test`
  - `mix test.coverage`
- Documentation verification:
  - update README Tool examples to use `Lti_1p3.Tool` as the canonical flow
  - ensure package docs name older modules as secondary or compatibility-facing if they remain public

## 14. Backwards Compatibility
- The design is additive at the provider boundary and mostly additive at the public Tool boundary.
- Existing `Lti_1p3.Tool.create_registration/1` and `create_deployment/1` remain available.
- Existing `Lti_1p3.Tool.OidcLogin` and `Lti_1p3.Tool.LaunchValidation` modules remain public for at least one transition period, but docs should treat them as secondary.
- Existing top-level lookup functions with raw `nil` or tuple return values should either:
  - be preserved and explicitly documented as legacy helpers, or
  - gain new normalized sibling functions while the older ones remain for compatibility.
- The FDD recommends avoiding an immediate breaking rename of provider callbacks or persisted structs in this slice.

## 15. Risks & Mitigations
- Risk: Public API drift between the new `Lti_1p3.Tool` functions and legacy modules.
  - Mitigation: implement top-level functions as the source of truth and delegate compatibility modules into them.
- Risk: Inconsistent error normalization hides useful provider or validation context.
  - Mitigation: standardize required keys while preserving contextual fields from underlying failures.
- Risk: Launch context abstraction becomes service-specific too early.
  - Mitigation: keep `LaunchContext` limited to core flow data needed across all Tool services.
- Risk: README and docs continue to point consumers at fragmented entry points.
  - Mitigation: treat documentation changes as part of the acceptance proof, not optional cleanup.
- Risk: Additive API changes still create confusion for existing consumers.
  - Mitigation: clearly document canonical versus compatibility surfaces and review release notes for migration language.

## 16. Open Questions & Follow-ups
- Should the normalized top-level lookup API replace `get_registration_by_issuer_client_id/2` in documentation immediately, or should both remain documented during one release cycle?
- Should `LaunchContext.claims` remain the raw verified claim map, or should this slice also define a higher-level normalized claims wrapper?
- Should the legacy `Lti_1p3.Tool.OidcLogin` and `Lti_1p3.Tool.LaunchValidation` modules emit deprecation warnings now, or should that wait until downstream Tool service APIs adopt the new top-level surface?

## 17. References
- `docs/exec-plans/current/core-tool-api-modernization/prd.md`
- `docs/exec-plans/current/core-tool-api-modernization/requirements.yml`
- `ARCHITECTURE.md`
- `harness.yml`
- `README.md`
- `docs/STACK.md`
- `docs/TOOLING.md`
- `docs/TESTING.md`
- `docs/PRODUCT_SENSE.md`
- `docs/FRONTEND.md`
- `docs/BACKEND.md`
- `docs/DESIGN.md`
- `docs/OPERATIONS.md`
- `docs/CODEREVIEW.md`
- `docs/ISSUE_TRACKING.md`
- `docs/design-docs/core-beliefs.md`
- `lib/lti_1p3/tool.ex`
- `lib/lti_1p3/tool/oidc_login.ex`
- `lib/lti_1p3/tool/launch_validation.ex`
- `lib/lti_1p3/data_provider.ex`
