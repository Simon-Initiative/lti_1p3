defmodule Lti_1p3.Tool.Registration do
  @enforce_keys [
    :issuer,
    :client_id,
    :key_set_url,
    :auth_token_url,
    :auth_login_url,
    :auth_server,
    :tool_jwk_id
  ]
  defstruct [
    :id,
    :issuer,
    :client_id,
    :key_set_url,
    :auth_token_url,
    :auth_login_url,
    :auth_server,
    :tool_jwk_id
  ]

  @type t() :: %__MODULE__{
    id: integer(),
    issuer: String.t(),
    client_id: String.t(),
    key_set_url: String.t(),
    auth_token_url: String.t(),
    auth_login_url: String.t(),
    auth_server: String.t(),
    tool_jwk_id: integer()
  }

end
