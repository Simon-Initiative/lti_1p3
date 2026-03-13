# Core Conformance Matrix

| Requirement | Module(s) | Status |
| --- | --- | --- |
| Unified tool login + launch APIs | `Lti_1p3.Tool`, `Lti_1p3.Tool.OidcLogin`, `Lti_1p3.Tool.LaunchValidation` | Implemented |
| Unified platform authorize API | `Lti_1p3.Platform`, `Lti_1p3.Platform.AuthorizationRedirect` | Implemented |
| Canonical error map (`reason/stage/msg/details`) | `Lti_1p3.Core.Errors`, core tool/platform flows | Implemented |
| Stage-based launch validation | `Lti_1p3.Core.Validation.*` | Implemented |
| Issuer/audience/time hardening | `Lti_1p3.Core.Validation.Jwt`, `...Timestamps` | Implemented |
| Nonce replay protection with deterministic reason | `Lti_1p3.Core.Validation.Nonce` | Implemented |
| Resource launch message validation | `Lti_1p3.Tool.MessageValidators.ResourceMessageValidator` | Implemented |
| Deep-linking request validation scaffold | `Lti_1p3.Tool.MessageValidators.DeepLinkingMessageValidator` | Implemented |
| Provider contract alignment | `Lti_1p3.DataProvider`, `Lti_1p3.DataProviders.MemoryProvider` | Implemented |
| Provider contract tests | `test/lti_1p3/provider_contracts_test.exs` | Implemented |
| Stage/outcome telemetry events | `Lti_1p3.Core.Telemetry`, tool/platform tests | Implemented |
| Documentation and migration guides | `README.md`, `docs/*.md` | Implemented |
