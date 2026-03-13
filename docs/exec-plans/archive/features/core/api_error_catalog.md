# Core API + Error Catalog

## Target Public APIs

- `Lti_1p3.Tool.login_redirect/2`
- `Lti_1p3.Tool.validate_launch/3`
- `Lti_1p3.Platform.authorize_redirect/5`

## Success Shapes

- Tool launch:
  - `{:ok, %Lti_1p3.Tool.Launch{...}}`
- Platform authorize redirect:
  - `{:ok, %Lti_1p3.Platform.AuthorizationPayload{...}}`

## Error Shape

```elixir
{:error, %{reason: atom(), stage: atom(), msg: String.t(), details: map()}}
```

## Stage Catalog

- Tool launch stages:
  - `:state`, `:registration`, `:jwt`, `:timestamps`, `:deployment`, `:message`, `:nonce`
- Platform authorize stages:
  - `:platform_registration`, `:oidc_params`, `:scope`, `:user`, `:client`, `:redirect`, `:nonce`, `:signing`, `:token_build`, `:claims`

## Reason Atom Catalog (core)

- `:invalid_oidc_state`
- `:missing_param`
- `:token_malformed`
- `:invalid_registration`
- `:missing_jwt_alg`
- `:invalid_jwt_alg`
- `:missing_kid`
- `:key_not_found`
- `:signature_error`
- `:invalid_issuer`
- `:invalid_audience`
- `:invalid_jwt_timestamp`
- `:invalid_deployment`
- `:invalid_message_type`
- `:invalid_message`
- `:invalid_deep_linking_request`
- `:invalid_nonce`
- `:client_not_registered`
- `:invalid_oidc_params`
- `:invalid_oidc_scope`
- `:invalid_login_hint`
- `:unauthorized_client`
- `:unauthorized_redirect_uri`
- `:missing_required_claims`
- `:token_build_failed`
