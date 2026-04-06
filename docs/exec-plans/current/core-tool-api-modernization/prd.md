# Core Tool API Modernization - Product Requirements Document

## 1. Overview
This feature modernizes the core Tool-side API in `lti_1p3` so consumers can register platforms, initiate OIDC login, and validate launches through a cohesive, high-level public surface. The feature should reduce manual assembly of low-level pieces while preserving the library’s storage and web-framework agnostic design.

## 2. Background & Problem Statement
The current Tool surface exposes useful primitives such as registrations, deployments, OIDC login, and launch validation, but the public API is still uneven and low-level. README examples show consumers composing multiple modules directly and handling framework details around state, registration lookup, and launch results. As the epic moves toward LTI Advantage Complete readiness, the Tool core flow needs a more consistent top-level API, clearer return shapes, and explicit support for certification-critical validation behavior before service-specific Tool features build on it.

## 3. Goals & Non-Goals
### Goals
- Provide a cohesive Tool-side public API for registration, deployment, OIDC login, and launch validation flows.
- Standardize Tool-side success and error return shapes for core launch operations.
- Preserve pure-data and functional integration patterns that do not require Plug, Phoenix, or a concrete datastore.
- Clarify the canonical Tool entry points that AGS, NRPS, and Deep Linking features should build on.
- Improve automated test coverage for Tool-side core happy paths and failure paths.
- Update docs and examples so consumers can implement core Tool flows from the supported API surface.

### Non-Goals
- Implementing AGS, NRPS, or Deep Linking feature behavior beyond what is necessary to preserve core Tool contracts.
- Shipping web routes, controllers, session storage, or frontend components.
- Adding a first-party durable data provider.
- Finalizing release-wide migration details for every downstream consumer; this feature only defines the Tool-side core contract it owns.

## 4. Users & Use Cases
- Tool developers: create registrations and deployments, initiate OIDC login redirects, and validate launches through top-level APIs with consistent errors.
- Maintainers: define a stable Tool-side API foundation that later Tool service features can depend on.
- Consumer application teams: plug Tool flow functions into Phoenix or other Elixir apps without introducing framework-specific dependencies into the library core.

## 5. UX / UI Requirements
- README and package docs must present the core Tool flow as a coherent sequence rather than as unrelated module calls.
- Tool-facing APIs should use consistent naming and return shapes so error handling is predictable across registration, login, and launch flows.
- Example integration snippets should make the boundary between library logic and application-owned session or request handling explicit.

## 6. Functional Requirements
Requirements are found in requirements.yml

## 7. Acceptance Criteria (Testable)
Requirements are found in requirements.yml

## 8. Non-Functional Requirements
- The Tool core API must remain storage agnostic through `Lti_1p3.DataProvider` behaviors.
- The Tool core API must remain web-framework agnostic and avoid accepting or returning Plug or Phoenix types.
- JWT validation, nonce handling, state handling expectations, deployment lookup, and key retrieval correctness must be preserved or improved.
- Public API behavior should favor explicit tuples, typed structs, and composable maps over implicit process state.
- Automated tests must cover both happy paths and negative paths for security-sensitive launch behavior.
- Documentation must stay aligned with the new Tool entry points.

## 9. Data, Interfaces & Dependencies
- Primary public surfaces are expected to center on `Lti_1p3.Tool` with supporting modules behind that entry point.
- The feature depends on existing Tool concerns in `Lti_1p3.Tool.Registration`, `Lti_1p3.Tool.Deployment`, `Lti_1p3.Tool.OidcLogin`, and `Lti_1p3.Tool.LaunchValidation`.
- Registration, deployment, and active JWK lookup must continue to delegate through configured providers.
- Remote platform JWK fetch and cache behavior remain shared dependencies for launch validation.
- This feature is a prerequisite for Tool-side AGS, NRPS, and Deep Linking feature work.

## 10. Repository & Platform Considerations
- Implementation and verification must fit current Mix, ExUnit, and coverage workflows.
- Existing `mix.exs` user changes must be preserved.
- Code review should prioritize Tool public API compatibility, launch security, provider semantics, and docs drift.
- The repository remains a library, so application-owned routes, controllers, and session storage stay outside scope.

## 11. Feature Flagging, Rollout & Migration
No feature flags present in this work item

## 12. Telemetry & Success Metrics
- Tool core APIs expose actionable and consistent error tuples suitable for downstream logging and observability.
- Automated Tool core tests expand over the current baseline for registration, login, launch, and failure-path coverage.
- README and package docs show an end-to-end Tool core flow based on the supported public API.

## 13. Risks & Mitigations
- API simplification could break existing Tool consumers: document canonical replacements and preserve compatibility intentionally where justified.
- Tool flow helpers could drift into framework ownership: keep library APIs centered on params, structs, claims, and explicit return values.
- Refactoring launch behavior could introduce security regressions: keep negative-path tests and spec-critical validation coverage in scope from the start.
- Service-specific concerns could leak into the core API: keep AGS, NRPS, and Deep Linking requirements out of this feature unless they change shared Tool contracts.

## 14. Open Questions & Assumptions
### Open Questions
- Should the new Tool API consolidate `OidcLogin` and `LaunchValidation` behind `Lti_1p3.Tool`, or should those modules remain public but secondary?
- How much backward compatibility should be preserved for existing Tool-facing module names and function signatures?
- Should launch validation return normalized claim structs, raw claims maps, or a richer result wrapper at the new top-level API?

### Assumptions
- Tool-side core work should complete before AGS Tool, NRPS Tool, and Deep Linking Tool features finalize their APIs.
- Registration, deployment, and key provider boundaries remain the correct persistence and runtime boundaries for the library.
- The library should continue to let consumer applications own session persistence for OIDC state and related browser concerns.

## 15. QA Plan
- Automated validation:
  - `mix compile --warnings-as-errors`
  - `mix test`
  - `mix test.coverage` for Tool core flow changes
  - Add or update ExUnit coverage for registration, deployment, OIDC login, launch validation, and negative-path security checks
- Manual validation:
  - Review README Tool examples against the implemented top-level API
  - Review return shapes and error tuples for consistency across Tool core flows
  - Confirm the resulting API stays independent of Plug, Phoenix, and concrete storage implementations

## 16. Definition of Done
- [ ] PRD sections complete
- [ ] requirements.yml captured and valid
- [ ] validation passes
