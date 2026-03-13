# Platform AGS Requirement Matrix

| Requirement | Status | Primary Modules | Tests |
| --- | --- | --- | --- |
| Enforce AGS scope/deployment/context authorization before each operation | Implemented | `Lti_1p3.Platform.Services.AGS`, `Lti_1p3.Platform.Services.AGS.ScopePolicy`, `Lti_1p3.Platform.Services.AGS.Context` | `test/lti_1p3/platform/services/ags_test.exs` |
| Implement typed platform AGS models for line item, score, result, and page payloads | Implemented | `Lti_1p3.Platform.Services.AGS.LineItem`, `Lti_1p3.Platform.Services.AGS.Score`, `Lti_1p3.Platform.Services.AGS.Result`, `Lti_1p3.Platform.Services.AGS.Page` | `test/lti_1p3/platform/services/ags_test.exs` |
| Implement line item list/create/read/update/delete operations | Implemented | `Lti_1p3.Platform.Services.AGS`, `Lti_1p3.Platform.Services.AGS.LineItems`, `Lti_1p3.DataProviders.MemoryProvider` | `test/lti_1p3/platform/services/ags_test.exs` |
| Implement score ingestion and result retrieval operations | Implemented | `Lti_1p3.Platform.Services.AGS`, `Lti_1p3.Platform.Services.AGS.Scores`, `Lti_1p3.Platform.Services.AGS.Results`, `Lti_1p3.DataProviders.MemoryProvider` | `test/lti_1p3/platform/services/ags_test.exs` |
| Normalize errors with stable reason atoms and HTTP semantics | Implemented | `Lti_1p3.Platform.Services.AGS.Errors` | `test/lti_1p3/platform/services/ags_test.exs` |
| Reuse extracted shared helpers from tool AGS paths | Implemented | `Lti_1p3.Services.AGS.ScopeSet`, `Lti_1p3.Services.HTTP.QueryFilters` | `test/lti_1p3/services/ags/scope_set_test.exs`, `test/lti_1p3/platform/services/ags_test.exs` |
| Emit platform AGS telemetry for requests, denials, errors, and outcomes | Implemented | `Lti_1p3.Platform.Services.AGS.Telemetry` | `test/lti_1p3/platform/services/ags_test.exs` |
| Document platform AGS integration guidance | Implemented | `docs/platform_ags_guide.md` | `mix docs` |
