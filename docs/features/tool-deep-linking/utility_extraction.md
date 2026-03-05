# Utility Extraction Candidates

## Extracted Helpers

1. `Lti_1p3.DeepLinking.ClaimKeys`
- Purpose: shared claim-key constants and lookup for deep-linking claims.
- Tool call sites:
  - `Lti_1p3.Tool.DeepLinking.RequestValidator`
  - `Lti_1p3.Tool.DeepLinking.ResponseBuilder`
  - `Lti_1p3.Tool.MessageValidators.DeepLinkingMessageValidator`
- Tests:
  - `test/lti_1p3/tool/deep_linking_test.exs`

## Next Reuse Targets (Platform Deep Linking)

1. Content item normalization and type alias handling (`ContentItem.normalize_type/1` logic shape).
2. Response/data correlation guard patterns (`ResponseBuilder.maybe_put_data/2` contract).
3. Deep-linking error reason catalog harmonization (`Tool.DeepLinking.Errors` reason atoms).
