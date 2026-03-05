# Tool Deep Linking Requirement Matrix

| Requirement | Status | Primary Modules | Tests |
| --- | --- | --- | --- |
| Validate `LtiDeepLinkingRequest` claims | Implemented | `Lti_1p3.Tool.DeepLinking.RequestValidator`, `Lti_1p3.Tool.MessageValidators.DeepLinkingMessageValidator` | `test/lti_1p3/tool/deep_linking_test.exs` |
| Parse typed deep-linking settings | Implemented | `Lti_1p3.Tool.DeepLinking.Settings` | `test/lti_1p3/tool/deep_linking_test.exs` |
| Build typed content items | Implemented | `Lti_1p3.Tool.DeepLinking.ContentItem` | `test/lti_1p3/tool/deep_linking_test.exs` |
| Build/sign deep-linking response JWT | Implemented | `Lti_1p3.Tool.DeepLinking.ResponseBuilder`, `Lti_1p3.Tool.DeepLinking.JwtSigner` | `test/lti_1p3/tool/deep_linking_test.exs` |
| Conditional response `data` handling | Implemented | `Lti_1p3.Tool.DeepLinking.ResponseBuilder` | `test/lti_1p3/tool/deep_linking_test.exs` |
| Compatibility controls for subtype variance | Implemented | `Lti_1p3.Tool.DeepLinking.CompatibilityPolicy` | `test/lti_1p3/tool/deep_linking_test.exs` |
| Structured errors for failures | Implemented | `Lti_1p3.Tool.DeepLinking.Errors` | `test/lti_1p3/tool/deep_linking_test.exs` |
| Telemetry/logging for request and response outcomes | Implemented | `Lti_1p3.Tool.DeepLinking.Telemetry` | `test/lti_1p3/tool/deep_linking_test.exs` |
| Utility extraction seams for platform reuse | Implemented | `Lti_1p3.DeepLinking.ClaimKeys` | `test/lti_1p3/tool/deep_linking_test.exs` |
