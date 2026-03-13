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
- Tool NRPS 2.0 APIs:
  - `Lti_1p3.Tool.Services.NRPS.from_launch_claim/1`
  - `Lti_1p3.Tool.Services.NRPS.list_memberships/3`
  - `Lti_1p3.Tool.Services.NRPS.stream_memberships/3`
  - `Lti_1p3.Tool.Services.NRPS.fetch_all_memberships/3`
- New tool NRPS modules for endpoint/page typing, parsing, scope policy, structured errors, telemetry, and HTTP client retry behavior.
- Shared HTTP helper modules for cross-role reuse:
  - `Lti_1p3.Services.HTTP.LinkHeader`
  - `Lti_1p3.Services.HTTP.QueryFilters`
- Tool NRPS guide (`docs/tool_nrps_guide.md`) and feature artifacts under `docs/features/tool-nrps/`.
- Tool AGS 2.0 APIs:
  - `Lti_1p3.Tool.Services.AGS.from_launch_claim/1`
  - `Lti_1p3.Tool.Services.AGS.list_line_items/3`
  - `Lti_1p3.Tool.Services.AGS.read_line_item/4`
  - `Lti_1p3.Tool.Services.AGS.create_line_item/4`
  - `Lti_1p3.Tool.Services.AGS.update_line_item/5`
  - `Lti_1p3.Tool.Services.AGS.delete_line_item/4`
  - `Lti_1p3.Tool.Services.AGS.post_score/5`
  - `Lti_1p3.Tool.Services.AGS.list_results/4`
  - `Lti_1p3.Tool.Services.AGS.fetch_all_results/4`
- New tool AGS modules for typed endpoint/page/result modeling, parsing, scope policy, structured errors, compatibility profile hooks, telemetry, and HTTP client retry behavior.
- Shared HTTP request helper module for cross-service reuse:
  - `Lti_1p3.Services.HTTP.Request`
- Tool AGS guide (`docs/tool_ags_guide.md`) and feature artifacts under `docs/features/tool-ags/`.
- Platform AGS 2.0 APIs:
  - `Lti_1p3.Platform.Services.AGS.authorize_operation/3`
  - `Lti_1p3.Platform.Services.AGS.list_line_items/2`
  - `Lti_1p3.Platform.Services.AGS.create_line_item/2`
  - `Lti_1p3.Platform.Services.AGS.read_line_item/2`
  - `Lti_1p3.Platform.Services.AGS.update_line_item/3`
  - `Lti_1p3.Platform.Services.AGS.delete_line_item/2`
  - `Lti_1p3.Platform.Services.AGS.post_score/3`
  - `Lti_1p3.Platform.Services.AGS.list_results/3`
- New platform AGS modules for typed context/model payloads, scope/deployment/context authorization, structured errors, telemetry, and provider-backed line item/score/result operations.
- Platform AGS guide (`docs/platform_ags_guide.md`) and feature artifacts under `docs/features/platform-ags/`.
- Shared AGS scope helper module for cross-role reuse:
  - `Lti_1p3.Services.AGS.ScopeSet`
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
- Existing `Lti_1p3.Tool.Services.NRPS.fetch_memberships/2` now runs through the stricter NRPS scope/filter/parser pipeline while preserving its legacy tuple shape.
- Shared query filter normalization now supports AGS filter keys (`resource_id`, `tag`, `user_id`) in addition to NRPS keys.
- Tool AGS scope policy now uses shared AGS scope utilities to align operation/scope mapping with platform AGS flows.
- `Lti_1p3.PlatformDataProvider` now includes AGS callbacks for line item, score, and result persistence boundaries.

### Removed

- Legacy Tool AGS compatibility helpers:
  - `Lti_1p3.Tool.Services.AGS.post_score/3`
  - `Lti_1p3.Tool.Services.AGS.fetch_line_items/2`
  - `Lti_1p3.Tool.Services.AGS.create_line_item/5`
  - `Lti_1p3.Tool.Services.AGS.update_line_item/3`
  - `Lti_1p3.Tool.Services.AGS.fetch_or_create_line_item/5`
- Legacy Tool AGS convenience helpers:
  - `Lti_1p3.Tool.Services.AGS.grade_passback_enabled?/1`
  - `Lti_1p3.Tool.Services.AGS.get_line_items_url/2`
  - `Lti_1p3.Tool.Services.AGS.has_scope?/2`
  - `Lti_1p3.Tool.Services.AGS.required_scopes/0`

### Fixed

- In-memory provider contract consistency and runtime implementation drift.
- Deterministic error shape alignment across core tool/platform flows.

### Migration Guide

Required changes:

- Migrate any legacy Tool AGS helper usage to typed AGS APIs.
- Update token scope requests to use `Lti_1p3.Tool.Services.AGS.required_scopes/1`.
- If you maintain a custom platform provider, implement new `Lti_1p3.PlatformDataProvider` AGS callbacks (`list_ags_line_items/3`, `create_ags_line_item/3`, `get_ags_line_item/3`, `update_ags_line_item/4`, `delete_ags_line_item/3`, `create_ags_score/4`, `list_ags_results/4`).

Upgrade steps:

1. Update to `lti_1p3` `1.0.0`.
2. Replace old AGS helper calls with `from_launch_claim/1` plus operation-specific APIs (`list_line_items/3`, `create_line_item/4`, `post_score/5`, `list_results/4`, etc.).
3. Run your normal validation suite (`mix test` and integration checks).
4. Update custom platform provider implementations to satisfy new Platform AGS behavior callbacks.
