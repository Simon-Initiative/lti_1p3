# Utility Extraction Notes

## Reused Helpers

1. `Lti_1p3.Services.AGS.ScopeSet`
- Purpose: Shared AGS scope constants, operation mappings, and scope parsing/lookup helpers.
- Platform call sites:
  - `Lti_1p3.Platform.Services.AGS.ScopePolicy`
- Tool call sites:
  - `Lti_1p3.Tool.Services.AGS.ScopePolicy`
- Tests:
  - `test/lti_1p3/services/ags/scope_set_test.exs`

2. `Lti_1p3.Services.HTTP.QueryFilters`
- Purpose: Normalize supported filters and compose request filter maps.
- Platform call sites:
  - `Lti_1p3.Platform.Services.AGS.LineItems`
  - `Lti_1p3.Platform.Services.AGS.Results`
- Tool call sites:
  - `Lti_1p3.Tool.Services.AGS`
  - `Lti_1p3.Tool.Services.NRPS`
- Tests:
  - `test/lti_1p3/services/http/query_filters_test.exs`
  - `test/lti_1p3/platform/services/ags_test.exs`
