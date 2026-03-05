# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] (Unreleased)

### Added

- Top-level unified APIs for tool and platform core flows:
  - `Lti_1p3.Tool.login_redirect/2`
  - `Lti_1p3.Tool.validate_launch/3`
  - `Lti_1p3.Platform.authorize_redirect/5`
- Tool deep-linking APIs:
  - `Lti_1p3.Tool.validate_deep_linking_request/1`
  - `Lti_1p3.Tool.deep_linking_content_item/2`
  - `Lti_1p3.Tool.build_deep_linking_response/3`
- New tool deep-linking modules for request validation, typed settings, content item building, compatibility policy hooks, response signing, and telemetry.
- Shared deep-linking claim key helper (`Lti_1p3.DeepLinking.ClaimKeys`) for cross-role reuse.
- Tool deep-linking guide (`docs/tool_deep_linking_guide.md`) and feature implementation artifacts under `docs/features/tool-deep-linking/`.
- Stage-based core validation modules for state, registration, JWT, timestamps, deployment, nonce, and message validation.
- Core telemetry events for validation stages and outcomes.
- Provider contract conformance tests and migration documentation.
- High-level integration and migration guides under `docs/`.
- Dedicated telemetry integration guide for client applications (`docs/telemetry.md`).

### Changed

- Tool launch validation now returns a normalized `%Lti_1p3.Tool.Launch{}` payload.
- Platform authorize flow now exposes a normalized `%Lti_1p3.Platform.AuthorizationPayload{}` payload.
- Message validator naming/path consistency fixed (`message_validators`).
- Deep-linking message dispatch now uses typed request/settings validation instead of scaffold-only checks.
- Audience and JWT validation hardening with explicit deterministic failure reasons.
- Core validation module layout was flattened from `Lti_1p3.Core.Validation.Stages.*` to `Lti_1p3.Core.Validation.*`.
- Core validation pipelines were simplified to explicit ordered stage calls (removed generic `run_stage` wrapper pattern).

### Fixed

- In-memory provider contract consistency and runtime implementation drift.
- Deterministic error shape alignment across core tool/platform flows.

### Migration Guide

Required changes:

- None

Upgrade steps:

1. Update to `lti_1p3` `1.0.0`.
2. Run your normal validation suite (`mix test` and integration checks).
