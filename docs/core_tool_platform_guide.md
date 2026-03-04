# Core Tool + Platform Guide

This guide documents the unified core APIs introduced for LTI 1.3 tool and platform flows.

## Tool API

### Build OIDC login redirect

```elixir
{:ok, %{state: state, redirect_url: redirect_url}} =
  Lti_1p3.Tool.login_redirect(params)
```

### Validate launch

```elixir
{:ok, %Lti_1p3.Tool.Launch{} = launch} =
  Lti_1p3.Tool.validate_launch(params, expected_state)
```

`Lti_1p3.Tool.validate_launch/3` returns deterministic error maps on failure:

```elixir
{:error, %{reason: :invalid_nonce, stage: :nonce, msg: "Duplicate nonce", details: %{}}}
```

## Platform API

### Authorize redirect

```elixir
{:ok, %Lti_1p3.Platform.AuthorizationPayload{} = payload} =
  Lti_1p3.Platform.authorize_redirect(params, current_user, issuer, claims)
```

`payload` contains `redirect_uri`, `state`, and signed `id_token`.

## Error Contract

Core APIs use the same error shape:

```elixir
%{reason: atom(), stage: atom(), msg: String.t(), details: map()}
```

## Telemetry

Core validation emits:

- `[:lti_1p3, :core, :validation, :stage]`
- `[:lti_1p3, :core, :validation, :outcome]`

Both include flow metadata (`:tool_launch` or `:platform_authorize_redirect`) and result (`:ok` / `:error`).

For full client integration details, see [Telemetry](telemetry.md).
