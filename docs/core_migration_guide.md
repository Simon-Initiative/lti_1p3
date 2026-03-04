# Core API Migration Guide

## Summary

The core tool/platform APIs are now unified under `Lti_1p3.Tool` and `Lti_1p3.Platform` with standardized tuple contracts and error maps.

## Tool changes

- Prefer `Lti_1p3.Tool.login_redirect/2` over directly calling `Lti_1p3.Tool.OidcLogin`.
- Prefer `Lti_1p3.Tool.validate_launch/3` over directly calling `Lti_1p3.Tool.LaunchValidation`.
- Launch success now returns `%Lti_1p3.Tool.Launch{}`.

## Platform changes

- Prefer `Lti_1p3.Platform.authorize_redirect/5` over directly calling `Lti_1p3.Platform.AuthorizationRedirect`.
- Success now returns `%Lti_1p3.Platform.AuthorizationPayload{}`.

## Error changes

All core failures now follow:

```elixir
{:error, %{reason: atom(), stage: atom(), msg: String.t(), details: map()}}
```

Update pattern matches to use `reason` and `stage` rather than message strings.

## Message validators

The typoed path `tool/message_vaildators` has been corrected to `tool/message_validators`.
Deep-linking request validation scaffolding is now included.
