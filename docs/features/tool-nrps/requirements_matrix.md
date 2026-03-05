# Tool NRPS Requirement Matrix

| Requirement | Status | Primary Modules | Tests |
| --- | --- | --- | --- |
| Parse NRPS launch claim into typed endpoint | Implemented | `Lti_1p3.Tool.Services.NRPS`, `Lti_1p3.Tool.Services.NRPS.Parser`, `Lti_1p3.Tool.Services.NRPS.Endpoint` | `test/lti_1p3/tool/services/nrps_test.exs` |
| Validate required NRPS scope before requests | Implemented | `Lti_1p3.Tool.Services.NRPS.ScopePolicy` | `test/lti_1p3/tool/services/nrps_test.exs` |
| Traverse paginated membership responses using `Link` | Implemented | `Lti_1p3.Tool.Services.NRPS`, `Lti_1p3.Tool.Services.NRPS.Client`, `Lti_1p3.Services.HTTP.LinkHeader` | `test/lti_1p3/tool/services/nrps_test.exs`, `test/lti_1p3/services/http/link_header_test.exs` |
| Support optional NRPS filters (`role`, `status`, `resource_link_id`, `limit`) | Implemented | `Lti_1p3.Tool.Services.NRPS`, `Lti_1p3.Services.HTTP.QueryFilters` | `test/lti_1p3/tool/services/nrps_test.exs`, `test/lti_1p3/services/http/query_filters_test.exs` |
| Normalize memberships to typed struct | Implemented | `Lti_1p3.Tool.Services.NRPS.Parser`, `Lti_1p3.Tool.Services.NRPS.Membership` | `test/lti_1p3/tool/services/nrps_test.exs` |
| Provide stream and eager fetch-all APIs | Implemented | `Lti_1p3.Tool.Services.NRPS` | `test/lti_1p3/tool/services/nrps_test.exs` |
| Return structured errors with retryability metadata | Implemented | `Lti_1p3.Tool.Services.NRPS.Errors`, `Lti_1p3.Tool.Services.NRPS.Client` | `test/lti_1p3/tool/services/nrps_test.exs` |
| Emit request/page/membership/error telemetry | Implemented | `Lti_1p3.Tool.Services.NRPS.Telemetry` | `test/lti_1p3/tool/services/nrps_test.exs` |
| Extract reusable link/filter helpers for platform reuse | Implemented | `Lti_1p3.Services.HTTP.LinkHeader`, `Lti_1p3.Services.HTTP.QueryFilters` | `test/lti_1p3/services/http/link_header_test.exs`, `test/lti_1p3/services/http/query_filters_test.exs` |
