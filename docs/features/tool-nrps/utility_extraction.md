# Utility Extraction Candidates

## Extracted Helpers

1. `Lti_1p3.Services.HTTP.LinkHeader`
- Purpose: parse `Link` headers and resolve `rel=\"next\"` traversal URLs.
- Tool call sites:
  - `Lti_1p3.Tool.Services.NRPS.Parser`
- Tests:
  - `test/lti_1p3/services/http/link_header_test.exs`

2. `Lti_1p3.Services.HTTP.QueryFilters`
- Purpose: normalize supported NRPS filter keys/values and compose request URLs.
- Tool call sites:
  - `Lti_1p3.Tool.Services.NRPS`
- Tests:
  - `test/lti_1p3/services/http/query_filters_test.exs`

## Next Reuse Targets (Platform NRPS)

1. Shared error reason catalog conventions (`insufficient_scope`, `request_failed`, `max_pages_exceeded`).
2. Common pagination traversal harness around `MembershipPage` with per-role adapters.
3. Shared telemetry naming conventions for tool/platform NRPS parity.
