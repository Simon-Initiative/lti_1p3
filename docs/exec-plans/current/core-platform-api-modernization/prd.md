# Core Platform API Modernization - Product Requirements Document

## 1. Overview
This feature modernizes the core Platform-side API in `lti_1p3` so consumers can manage tool integrations, create login hints, and authorize launches through a cohesive, high-level public surface. The feature should establish a stable Platform foundation that later AGS, NRPS, and Deep Linking Platform features can build on.

## 2. Background & Problem Statement
The current Platform surface is narrower than the Tool surface and appears split across `Lti_1p3.Platform`, `Lti_1p3.Platform.LoginHints`, and `Lti_1p3.Platform.AuthorizationRedirect`. README examples require consumers to wire together platform instance management, current-user handling, login hints, claims, and redirect rendering manually. Before service-specific Platform features can be specified cleanly, the library needs a canonical Platform entry point, consistent return shapes, and explicit handling of certification-critical launch-building behavior.

## 3. Goals & Non-Goals
### Goals
- Provide a cohesive Platform-side public API for platform instance management, login hints, and authorization redirect flows.
- Standardize Platform-side success and error return shapes for core launch-building operations.
- Preserve pure-data and functional integration patterns that do not require Plug, Phoenix, or a concrete datastore.
- Clarify the canonical Platform entry points that AGS, NRPS, and Deep Linking Platform features should build on.
- Improve automated test coverage for Platform core happy paths and failure paths.
- Update docs and examples so consumers can implement core Platform flows from the supported API surface.

### Non-Goals
- Implementing AGS, NRPS, or Deep Linking Platform service behavior beyond what is necessary to preserve core Platform contracts.
- Shipping web routes, controllers, rendered forms, session storage, or frontend components.
- Adding a first-party durable data provider.
- Defining final service-specific Platform APIs for grade, roster, or deep-linking request behavior.

## 4. Users & Use Cases
- Platform developers: create and manage platform instances, generate and validate login hints, and authorize launches through documented top-level APIs.
- Maintainers: define a stable Platform-side API foundation that later Platform service features can depend on.
- Consumer application teams: plug Platform flow functions into Phoenix or other Elixir apps while keeping user session checks and rendering under application control.

## 5. UX / UI Requirements
- README and package docs must present the core Platform flow as a coherent sequence rather than as unrelated module calls.
- Platform-facing APIs should use consistent naming and return shapes so error handling is predictable across platform instance, login hint, and launch authorization flows.
- Example integration snippets should make the boundary between library logic and application-owned current-user/session/rendering concerns explicit.

## 6. Functional Requirements
Requirements are found in requirements.yml

## 7. Acceptance Criteria (Testable)
Requirements are found in requirements.yml

## 8. Non-Functional Requirements
- The Platform core API must remain storage agnostic through `Lti_1p3.DataProvider` behaviors.
- The Platform core API must remain web-framework agnostic and avoid accepting or returning Plug or Phoenix types.
- Login hint handling, launch claim construction, signing behavior, and authorization redirect correctness must be preserved or improved.
- Public API behavior should favor explicit tuples, typed structs, and composable maps over implicit process state.
- Automated tests must cover both happy paths and negative paths for security-sensitive Platform behavior.
- Documentation must stay aligned with the new Platform entry points.

## 9. Data, Interfaces & Dependencies
- Primary public surfaces are expected to center on `Lti_1p3.Platform` with supporting modules behind that entry point.
- The feature depends on existing Platform concerns in `Lti_1p3.Platform.PlatformInstance`, `Lti_1p3.Platform.LoginHints`, and `Lti_1p3.Platform.AuthorizationRedirect`.
- Platform instance and login hint persistence must continue to delegate through configured providers.
- Active JWK access and token signing remain shared dependencies for authorization redirect behavior.
- This feature is a prerequisite for Platform-side AGS, NRPS, and Deep Linking feature work.

## 10. Repository & Platform Considerations
- Implementation and verification must fit current Mix, ExUnit, and coverage workflows.
- Existing `mix.exs` user changes must be preserved.
- Code review should prioritize Platform public API compatibility, launch security, provider semantics, and docs drift.
- The repository remains a library, so application-owned routes, controllers, user session checks, and rendered responses stay outside scope.

## 11. Feature Flagging, Rollout & Migration
No feature flags present in this work item

## 12. Telemetry & Success Metrics
- Platform core APIs expose actionable and consistent error tuples suitable for downstream logging and observability.
- Automated Platform core tests expand over the current baseline for platform instance, login hint, authorization redirect, and failure-path coverage.
- README and package docs show an end-to-end Platform core flow based on the supported public API.

## 13. Risks & Mitigations
- API simplification could break existing Platform consumers: document canonical replacements and preserve compatibility intentionally where justified.
- Platform helpers could drift into controller or rendering ownership: keep library APIs centered on params, claims, structs, and explicit return values.
- Refactoring authorization redirect behavior could introduce signing or claim-construction regressions: keep negative-path tests and spec-critical coverage in scope from the start.
- Service-specific concerns could leak into the core Platform API: keep AGS, NRPS, and Deep Linking requirements out of this feature unless they change shared Platform contracts.

## 14. Open Questions & Assumptions
### Open Questions
- Should the new Platform API consolidate login hint and authorization redirect operations behind `Lti_1p3.Platform`, or should those modules remain public but secondary?
- How much backward compatibility should be preserved for existing Platform-facing module names and function signatures?
- Should authorization redirect return a richer normalized result object in addition to target URI, state, and signed token?

### Assumptions
- Platform-side core work should complete before AGS Platform, NRPS Platform, and Deep Linking Platform features finalize their APIs.
- Platform instance, login hint, and JWK boundaries remain the correct persistence and runtime boundaries for the library.
- The library should continue to let consumer applications own current-user validation, request lifecycle, and final HTML form rendering.

## 15. QA Plan
- Automated validation:
  - `mix compile --warnings-as-errors`
  - `mix test`
  - `mix test.coverage` for Platform core flow changes
  - Add or update ExUnit coverage for platform instance management, login hints, authorization redirect, and negative-path security checks
- Manual validation:
  - Review README Platform examples against the implemented top-level API
  - Review return shapes and error tuples for consistency across Platform core flows
  - Confirm the resulting API stays independent of Plug, Phoenix, and concrete storage implementations

## 16. Definition of Done
- [ ] PRD sections complete
- [ ] requirements.yml captured and valid
- [ ] validation passes
