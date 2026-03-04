# AGENTS.md

## Project Scope

- Maintain and extend `lti_1p3`, an Elixir library implementing LTI 1.3 platform and tool flows.
- Keep the library framework-agnostic while integrating cleanly with Phoenix and other Plug-based apps.
- Prioritize protocol correctness, security guarantees, and backward-compatible public APIs.
- Support both in-memory defaults and pluggable persistence/key management for production deployments.

## Overview

- Primary domains:
  - Tool-side launch flow (`Lti_1p3.Tool.*`) including OIDC login and launch validation.
  - Platform-side launch flow (`Lti_1p3.Platform.*`) including authorization redirect and login hint handling.
  - Security primitives: JWK handling, JWT validation, nonce protection, and key retrieval/caching.
- Entry points:
  - `Lti_1p3` for shared operations (JWKs, key cache management).
  - `Lti_1p3.Tool` and `Lti_1p3.Platform` for role-specific workflows.
- Persistence is abstracted via behavior contracts (`Lti_1p3.DataProvider`, `Lti_1p3.ToolDataProvider`, `Lti_1p3.PlatformDataProvider`).

## Key Architectural Patterns

- Behavior-driven boundaries:
  - Core persistence and key retrieval are behind behavior contracts.
  - Production adapters can be swapped without changing business logic.
- OTP supervision for key management:
  - `Lti_1p3.KeyProviderSupervisor` hosts key-provider processes.
  - Key cache refresh is interval-driven and configurable.
- Functional validation pipelines:
  - Critical launch validation uses `with` chains and tagged tuples (`{:ok, value}` / `{:error, reason}`).
  - Fail-fast execution preserves clear reason codes for callers.
- Security-first defaults:
  - Nonce uniqueness checks prevent replay.
  - JWT timestamp checks include modest clock-skew tolerance.
  - Public key lookup is centralized through key providers.

## Engineering Workflow

1. Create feature architecture docs under `docs/features/<feature-slug>/`:
   - `prd.md`
   - `fdd.md`
   - `plan.md`
2. Treat phases in `plan.md` as cohesive functional slices and execute them in order.
3. If the feature is too large for one PR, group one or more sequential phases into PR groups that can be delivered independently.
4. During implementation, update `plan.md` checkboxes as tasks/phases are completed.
5. Keep the final phase as manual QA acceptance testing before feature completion.
6. Confirm scope and affected LTI surface area (Tool, Platform, shared security, provider contracts).
7. Read relevant behavior contracts before modifying implementations.
8. Add/update tests in `test/lti_1p3/**` for success and failure paths.
9. Run formatting and tests before finalizing.
10. Update docs (`README.md` and/or `docs/*.md`) when behavior changes.
11. Update top-level `CHANGELOG.md` for every implemented feature or bug fix:

- Add a high-level summary under `## [Unreleased]`.
- Use Keep a Changelog sections (`Added`, `Changed`, `Fixed`, etc.).
- Keep entries concise and integration-focused (not line-by-line diffs).

12. Keep migration guidance up to date whenever necessary for any changes made:

- Add/update a `Migration Guide` section directly in `CHANGELOG.md` under the relevant release when client app migrations and/or infrastructure changes are required.
- Include: required changes and concise upgrade steps.

## Coding Style Guidelines

- Follow standard Elixir formatting; run `mix format` for all touched files.
- Prefer pure functions and pattern matching over nested conditionals.
- Keep public API return shapes stable; use tagged tuples for recoverable errors.
- Reserve exceptions for misconfiguration or truly exceptional conditions.
- Keep `@doc` and `@spec` on public functions and behaviors accurate.
- Use descriptive reason atoms in error maps (example: `:invalid_registration`, `:invalid_nonce`).
- Keep modules focused by domain (`Tool`, `Platform`, `Claims`, `Roles`, `Services`, `KeyProviders`).

## Common Development Tasks

- Install/update deps: `mix deps.get`
- Compile: `mix compile`
- Run full test suite: `mix test`
- Run a single test file: `mix test test/lti_1p3/tool/launch_validation_test.exs`
- Run a single test line: `mix test test/lti_1p3/tool/launch_validation_test.exs:42`
- Coverage (configured alias): `mix test.coverage`
- XML coverage alias: `mix test.coverage.xml`
- Format codebase: `mix format`
- Generate docs: `mix docs`

## Important Considerations

- Never expose private JWK material; only publish public JWK sets.
- LTI launch correctness depends on validating `state`, nonce, JWT signature, `exp/iat`, registration, and deployment.
- Provider configuration is mandatory for real persistence; in-memory defaults are volatile and test-oriented.
- Key-provider supervision should be included in host apps that rely on key caching/refresh.
- Avoid breaking return tuple shapes or error reason atoms; downstream apps may pattern-match them.
- Keep security-sensitive defaults explicit in config (`nonce`/`login_hint` TTLs, key-cache TTL/refresh intervals).

## Debugging Tips

- For JWT investigation, inspect token claims/header early to confirm issuer, audience, `kid`, deployment, and message type.
- Validate key retrieval paths with cache tooling:
  - `Lti_1p3.key_cache_info/0`
  - `Lti_1p3.refresh_all_keys/0`
  - `Lti_1p3.clear_key_cache/0`
- Reproduce launch failures by isolating each validation stage (state, registration, signature, timestamps, deployment, nonce).
- In tests, keep mocks deterministic and assert exact failure reasons, not only `{:error, _}`.
- When debugging browser-embedded launches, verify cookie/session behavior in iframe contexts.

## LTI 1.3 Specification References

- LTI 1.3 Core: https://site.imsglobal.org/standards/lti/lti-1p3/1p3
- IMS Security Framework 1.0: https://www.imsglobal.org/spec/security/v1p0/
- LTI Deep Linking 2.0: https://site.imsglobal.org/standards/lti/lti-dl/2p0
- LTI Names and Role Provisioning Services 2.0: https://site.imsglobal.org/standards/lti/lti-nrps/2p0
- LTI Assignment and Grade Services 2.0: https://site.imsglobal.org/standards/lti/lti-ags/2p0
- LTI 1.3 Implementation Guide: https://www.imsglobal.org/spec/lti/v1p3/impl/
