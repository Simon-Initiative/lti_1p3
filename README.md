# Lti1p3

LTI 1.3 Library for Elixir based Tools and Platforms.

This library provides the capability to handle LTI 1.3 launch requests as a Tool and also issue requests as a Platform. You can use this library to develop an LTI 1.3 compliant Tool or Platform or both. The data persistence is customizable by specifying a provider that conforms to the DataProvider behavior.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `lti_1p3` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lti_1p3, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/lti_1p3](https://hexdocs.pm/lti_1p3).

## Getting Started

Add the following to `config/config.exs`:
```
use Mix.Config

# ... existing config

config :lti_1p3,
  provider: Lti_1p3.DataProviders.MemoryProvider

# ... import_config

```

The provider configured here is an example in-memory persistence provider which means any registrations or deployments created will be lost when your app is shutdown. To properly perisit this data across restarts you will need to specify another provider such as the [EctoProvider](https://github.com/Simon-Initiative/lti_1p3_ecto_provider) or a custom implementation of the [DataProvider](./lib/lti_1p3/data_provider.ex) behavior.

### LTI 1.3 Tool Example

If you are unfamiliar with LTI 1.3, please refer to the the [LTI 1.3 Launch Overview](./docs/lti_1p3_overview.md).

Before a launch can be performed, registration must exist for the Platform by creating a Jwk, Registration and Deployment. A registration represents the details provided by a platform administrator. For the simplest case, if your tool only needs to integrate with a single platform this can be hardcoded in at startup or in a simple database seed script. For the more common case, if your tool needs to support multiple runtime-configurable platform integrations, this registration process will most likely be implemented in something more akin to a web form, such as using a Phoenix controller.

```elixir
# Create an active Jwk. Typically this is done once at startup, in a database seed script or when keys are rotated by the tool.
# This will be reused across registration creations
%{private_key: private_key} = Lti_1p3.KeyGenerator.generate_key_pair()
{:ok, jwk} = Lti_1p3.create_jwk(%Lti_1p3.Jwk{
  pem: private_key,
  typ: "JWT",
  alg: "RS256",
  kid: "some-unique-kid",
  active: true,
})

# Create a Registration, Details are typically provided by the platform administrator for this registration.
{:ok, registration} = Lti_1p3.Tool.create_registration(%Lti_1p3.Tool.Registration{
  issuer: "https://platform.example.edu",
  client_id: "1000000000001",
  key_set_url: "https://platform.example.edu/.well-known/jwks.json",
  auth_token_url: "https://platform.example.edu/access_tokens",
  auth_login_url: "https://platform.example.edu/authorize_redirect",
  auth_server: "https://platform.example.edu",
  tool_jwk_id: jwk.id,
})

# Create a Deployment. Essentially this a unique identifier for a specific registration launch point,
# for which there can be many for a single registration. This will also typically be provided by a
# platform administrator.
{:ok, _deployment} = Lti_1p3.Tool.create_deployment(%Lti_1p3.Tool.Deployment{
  deployment_id: "some-deployment-id",
  registration_id: registration.id,
})

```

Your tool implementation will need to have 2 endpoints for handling lti requests. The first will be a `login` endpoint, which will issue a login request back to the platform. The second will be a `launch` endpoint, which will validate the lti launch details and if successful, cache the LTI params from the request and display the resource. The details of both of these steps is outlined in the [LTI 1.3 Launch Overview](./docs/lti_1p3_overview.md). You will need to provide both of these endpoint urls to the platform as part of their registration process for your tool.

The first endpoint, `login`, uses the `Lti_1p3.Tool.OidcLogin` module to validate the request and return a state key and redirect_uri. For example:

```elixir
defmodule MyToolWeb.LtiController do
  use MyToolWeb, :controller

  def login(conn, params) do
    case Lti_1p3.OidcLogin.oidc_login_redirect_url(params) do
      {:ok, state, redirect_url} ->
        conn
        |> put_session("state", state)
        |> redirect(external: redirect_url)

      {:error, %{reason: :invalid_registration, msg: _msg, issuer: issuer, client_id: client_id}} ->
        handle_invalid_registration(conn, issuer, client_id)

      {:error, %{reason: _reason, msg: msg}} ->
        render(conn, "lti_error.html", msg: msg)
    end
  end

  ...

end
```

Notice how the returned state is stored in the session so that it can be used later in the launch request. The user is then redirected to the returned redirect_url. In the case where an error is returned, a map with the reason code, error message, and any additional data associated with the specific error is returned and can be handled accordingly.

The second endpoint, `launch`, uses the `Lti_1p3.Tool.LaunchValidation` module to validate the launch and cache the lti params. For example:

```elixir
defmodule MyToolWeb.LtiController do
  use MyToolWeb, :controller

  ...

  def launch(conn, params) do
    session_state = Plug.Conn.get_session(conn, "state")
    case Lti_1p3.Tool.LaunchValidation.validate(params, session_state) do
      {:ok, lti_params, sub} ->
        # store sub in the session so that the cached lti_params can be retrieved in later requests
        conn = conn
          |> Plug.Conn.put_session(:lti_1p3_sub, sub)

        handle_valid_lti_1p3_launch(conn, lti_params)

      {:error, %{reason: :invalid_registration, msg: _msg, issuer: issuer, client_id: client_id}} ->
        handle_invalid_registration(conn, issuer, client_id)

      {:error, %{reason: :invalid_deployment, msg: _msg, registration_id: registration_id, deployment_id: deployment_id}} ->
        handle_invalid_deployment(conn, registration_id, deployment_id)

      {:error, %{reason: _reason, msg: msg}} ->
        render(conn, "lti_error.html", reason: msg)
    end
  end

end
```

If successful, `validate` returns the LTI params from the request as well as the `sub` for a user, which can be used to retrieve the the LTI params associated with the user's latest launch by using the `Lti_1p3.Tool` module.

```elixir
%Lti_1p3.Tool.LtiParams{params: lti_params} = Lti_1p3.Tool.get_lti_params_by_sub(sub)
```

If you are using Phoenix, don't forget to add these endpoints to your `router.ex`. The LTI 1.3 specification says the `login` request can be sent as either a `GET` or `POST`, so we must support both methods.

```elixir
    post "/login", LtiController, :login
    get "/login", LtiController, :login
    post "/launch", LtiController, :launch
```

> **Additional Note:**
> As modern browsers continue to limit the ability of iFrames to set cookies from within a page from another domain (which is usually how an LTI page is displayed by default) it becomes more unreliable to use cookie-based session storage for things like `state` and `lti_1p3_sub` key. If you run into issues related to session data not being stored consistently across requests, please verify that the cookie is actually being set in the browser and also try initiating the launch into a new tab instead of in an iframe.

### LTI 1.3 Platform Example

If you are unfamiliar with LTI 1.3, please refer to the the [LTI 1.3 Launch Overview](./docs/lti_1p3_overview.md).

