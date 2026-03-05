# Utility Extraction Candidates

## Extracted Helpers

1. `Lti_1p3.Services.HTTP.Request`
- Purpose: bearer header composition and path-safe endpoint concatenation.
- Tool call sites:
  - `Lti_1p3.Tool.Services.AGS.Client`
  - `Lti_1p3.Tool.Services.AGS`
  - `Lti_1p3.Tool.Services.NRPS.Client`
- Tests:
  - Covered indirectly through AGS/NRPS client/service tests.

2. `Lti_1p3.Services.HTTP.LinkHeader`
- Purpose: parse `Link` headers and resolve `rel="next"` traversal URLs.
- Tool call sites:
  - `Lti_1p3.Tool.Services.AGS.Parser`
  - `Lti_1p3.Tool.Services.NRPS.Parser`
- Tests:
  - `test/lti_1p3/services/http/link_header_test.exs`

3. `Lti_1p3.Services.HTTP.QueryFilters`
- Purpose: normalize supported filters and compose request URLs.
- Tool call sites:
  - `Lti_1p3.Tool.Services.AGS`
  - `Lti_1p3.Tool.Services.NRPS`
- Tests:
  - `test/lti_1p3/services/http/query_filters_test.exs`

## Next Reuse Targets (Platform AGS)

1. Shared scope-policy primitives (`required_scopes_for/1` style operation mapping).
2. Shared error reason conventions (`insufficient_scope`, `request_failed`, `max_pages_exceeded`).
3. Shared pagination traversal harness around typed page structs.
