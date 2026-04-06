# LTI Advantage Complete Modernization Epic - Product Requirements Document

## 1. Overview
This work item defines the epic for the next major version of `lti_1p3` as a certification-ready Elixir library for both Tool and Platform integrations. The epic coordinates a set of child features that simplify the public API, close specification coverage gaps, and raise automated test coverage so downstream applications can implement complete LTI 1.3 and LTI Advantage flows with fewer low-level decisions and less framework-specific glue.

## 2. Background & Problem Statement
The repository already exposes Tool and Platform modules plus AGS, NRPS, claim parsing, key management, and launch-flow primitives, but the public surface is uneven and still requires consumers to assemble important flows manually. Platform support appears narrower than Tool support, deep linking is not yet presented as a complete end-to-end capability across both sides, and the library needs clearer boundaries around certification-critical behavior. To pursue 1EdTech LTI Advantage Complete certification, the next version must align the package with LTI Core 1.3 plus Deep Linking 2.0, Names and Role Provisioning Services 2.0, and Assignment and Grade Services 2.0 for both Tool and Platform modules while preserving the library’s storage and web-framework agnostic design. This breadth makes the work too large for a single feature track, so this PRD now acts as an epic that governs multiple child features with explicit dependency sequencing.

## 3. Goals & Non-Goals
### Goals
- Define the epic scope and child feature boundaries needed to deliver LTI Advantage Complete readiness.
- Coordinate a dependency-ordered rollout for Tool and Platform LTI Core, AGS, NRPS, and Deep Linking features.
- Preserve common cross-cutting constraints across all child features, including functional API design, storage agnosticism, framework agnosticism, security posture, documentation quality, and coverage expectations.
- Establish release-level success criteria for certification readiness, API modernization, and test coverage uplift.
- Provide a planning artifact that follow-on design and implementation work can use without re-scoping the entire initiative.

### Non-Goals
- Shipping a Phoenix application, routes, controllers, HTML UI, or a JavaScript frontend.
- Adding a first-party durable database provider to this repository.
- Supporting non-LTI protocols or custom vendor extensions beyond what is required for interoperable integrations.
- Collapsing all implementation detail into this epic instead of managing service and role-specific work through child features.
- Defining the detailed architecture, module split, or migration mechanics for implementation; that belongs in follow-on design artifacts.

## 4. Users & Use Cases
- Tool developers: consume the resulting child features to register platforms, handle OIDC login and launches, execute AGS and NRPS calls, and complete deep-linking flows through stable top-level APIs.
- Platform developers: consume the resulting child features to register tools, authorize launches, expose AGS and NRPS capabilities, and complete deep-linking request and response flows through stable top-level APIs.
- Maintainers: use the epic to sequence feature work, verify library behavior against LTI and 1EdTech certification expectations, and keep requirements traceable across multiple work items.
- Consumer application teams: integrate the library into Phoenix or other Elixir applications without adopting a required storage backend or web framework abstraction.

## 5. UX / UI Requirements
- Public API documentation and examples must act as the primary user experience because this repository has no owned frontend.
- Child features should converge on consistent naming, return shapes, and error conventions so integrators can reason about Tool and Platform APIs with the same patterns.
- Certification-critical flows should ultimately be documented as end-to-end examples for both Tool and Platform consumers, even though those docs may land incrementally by child feature.

## 6. Functional Requirements
Requirements are found in requirements.yml

## 7. Acceptance Criteria (Testable)
Requirements are found in requirements.yml

## 8. Non-Functional Requirements
- The library must preserve storage/backend agnosticism through provider boundaries rather than embedding persistence assumptions.
- The library must remain web-framework agnostic and avoid owning request routing, controller rendering, or session implementations.
- Security-sensitive behavior must maintain or improve correctness for nonce handling, JWT validation, key retrieval, key caching, and service authorization flows.
- Child feature APIs should prefer functional, explicit return values and composable data structures over implicit process or framework coupling.
- Certification-critical behavior must be validated by automated tests for normal flows, error handling, and spec-required edge cases.
- Public documentation must remain aligned with the implemented API and release expectations for a package-oriented rollout.
- Performance-sensitive paths should avoid unnecessary remote key fetches, repeated parsing, or avoidable service-call overhead in hot paths.

## 9. Data, Interfaces & Dependencies
- Core public surfaces are expected to remain `Lti_1p3`, `Lti_1p3.Tool`, and `Lti_1p3.Platform`, with supporting modules behind those entry points.
- Persistence must continue to flow through `Lti_1p3.DataProvider` behaviors rather than concrete repository-owned storage.
- Remote JWK retrieval and service calls continue to depend on outbound HTTP abstractions and test-time HTTP mocks.
- The work depends on the LTI 1.3, AGS 2.0, Deep Linking 2.0, and NRPS 2.0 specifications plus 1EdTech LTI certification expectations as the interoperability source of truth.
- Documentation updates in `README.md` and related docs are part of the deliverable because package guidance is part of the product surface.
- Child features and dependency order are tracked in `child-features.md` within this work item directory.

## 10. Repository & Platform Considerations
- The repository is an Elixir library built with Mix and ExUnit, so implementation and verification must fit the existing compile, test, coverage, and docs workflows.
- Existing user changes in `mix.exs` must be preserved unless explicitly requested otherwise.
- Review should prioritize public API compatibility, security-sensitive flows, provider semantics, and documentation drift per `docs/CODEREVIEW.md`.
- Issue intake and release planning should assume GitHub-based maintenance workflows because no repo-local issue tracker provider is configured.
- The package should continue to support integrators who run it inside Phoenix or other Elixir apps without requiring repository-owned infrastructure.
- Epic completion depends on coordinated completion of child features rather than a single implementation branch.

## 11. Feature Flagging, Rollout & Migration
No feature flags present in this work item

## 12. Telemetry & Success Metrics
- Track release readiness with passing certification-targeted automated suites for Tool and Platform LTI Core, AGS, NRPS, and Deep Linking flows across the child feature set.
- Track improved package confidence through increased automated test coverage over the current baseline, especially in public API and security-sensitive modules touched by child features.
- Track adoption readiness through updated examples and docs that cover supported Tool and Platform integration paths without requiring framework-specific assumptions.
- Track operational quality indirectly through preserved logger compatibility and actionable error tuples for downstream applications.

## 13. Risks & Mitigations
- Specification ambiguity or incomplete flow coverage could block certification: map implementation scope explicitly to LTI Core, AGS, NRPS, and Deep Linking requirements before coding.
- Public API simplification could introduce breaking changes that surprise existing consumers: define compatibility and migration expectations early and document them in release guidance.
- Platform responsibilities may require broader expansion than current code organization anticipates: treat Tool and Platform parity as an explicit design constraint in child feature design.
- Test coverage improvements may still miss certification edge cases: add certification-oriented behavior tests and negative-path cases rather than only unit happy paths.
- Cross-feature sequencing mistakes could create rework in public APIs: finish core API direction before service-specific features depend on it.
- Framework agnostic goals could erode if convenience helpers depend on Plug, Phoenix, or a specific datastore: keep new APIs centered on pure data transforms and explicit boundary behaviors.

## 14. Open Questions & Assumptions
### Open Questions
- Is the target release allowed to make semver-major breaking API changes, or must it preserve selected compatibility shims for existing consumers?
- Will certification be executed during this work item or is certification-readiness with documented evidence sufficient for the first release cut?
- Which existing public modules are considered canonical long-term entry points versus candidates for consolidation behind higher-level utilities?
- Does “increase unit test coverage” need a numeric threshold for this release, or is directional improvement on certification-critical paths sufficient?
- Should certification evidence and coverage uplift be tracked as a dedicated child feature or absorbed into every service-specific child feature?

### Assumptions
- The target outcome is a major-version library release rather than an incremental patch to the current API.
- 1EdTech LTI Advantage Complete implies LTI Core 1.3 plus Deep Linking 2.0, NRPS 2.0, and AGS 2.0 support.
- Both Tool and Platform support must be first-class in the public API and documentation, not only present as lower-level modules.
- Documentation, examples, and tests are release-critical because the repository is a reusable package rather than a deployable service.
- Child features will be managed as separate work items beneath this epic rather than as sections inside a single implementation plan.

## 15. QA Plan
- Automated validation:
  - Validate this epic PRD and requirements plus follow-on child feature artifacts.
  - Use `mix compile --warnings-as-errors`, `mix test`, and `mix test.coverage` in child features that change library code.
  - Add or update ExUnit coverage for Tool and Platform launch flows, AGS, NRPS, deep linking, key management, and error handling in the relevant child features.
- Manual validation:
  - Review the child feature list and dependency ordering for completeness before spinning out feature-level PRDs.
  - Confirm certification scope mapping covers supported Tool and Platform responsibilities for LTI Core, AGS, NRPS, and Deep Linking.
  - Review return shapes and error tuples for consistency across top-level Tool and Platform APIs as child features are specified and implemented.

## 16. Definition of Done
- [ ] PRD sections complete
- [ ] requirements.yml captured and valid
- [ ] validation passes
