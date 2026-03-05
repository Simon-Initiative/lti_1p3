# Tool AGS Requirement Matrix

| Requirement | Status | Primary Modules | Tests |
| --- | --- | --- | --- |
| Parse AGS launch claim into typed endpoint | Implemented | `Lti_1p3.Tool.Services.AGS`, `Lti_1p3.Tool.Services.AGS.Parser`, `Lti_1p3.Tool.Services.AGS.Endpoint` | `test/lti_1p3/tool/services/ags_test.exs` |
| Validate required AGS scopes before each operation | Implemented | `Lti_1p3.Tool.Services.AGS.ScopePolicy` | `test/lti_1p3/tool/services/ags_test.exs` |
| Implement line item list/create/read/update/delete coverage | Implemented | `Lti_1p3.Tool.Services.AGS`, `Lti_1p3.Tool.Services.AGS.Client` | `test/lti_1p3/tool/services/ags_test.exs` |
| Implement score posting validation and execution | Implemented | `Lti_1p3.Tool.Services.AGS`, `Lti_1p3.Tool.Services.AGS.Parser` | `test/lti_1p3/tool/services/ags_test.exs` |
| Implement results retrieval with pagination traversal | Implemented | `Lti_1p3.Tool.Services.AGS`, `Lti_1p3.Tool.Services.AGS.Parser`, `Lti_1p3.Services.HTTP.LinkHeader` | `test/lti_1p3/tool/services/ags_test.exs`, `test/lti_1p3/services/http/link_header_test.exs` |
| Return structured AGS errors with operation/http/retry metadata | Implemented | `Lti_1p3.Tool.Services.AGS.Errors`, `Lti_1p3.Tool.Services.AGS.Client` | `test/lti_1p3/tool/services/ags_test.exs` |
| Emit request/scope-denial/outcome telemetry | Implemented | `Lti_1p3.Tool.Services.AGS.Telemetry` | `test/lti_1p3/tool/services/ags_test.exs` |
| Provide compatibility profile hooks for LMS variance | Implemented | `Lti_1p3.Tool.Services.AGS.CompatibilityPolicy` | `test/lti_1p3/tool/services/ags_test.exs` |
