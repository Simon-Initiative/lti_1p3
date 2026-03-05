defmodule Lti_1p3.Tool.DeepLinking.Request do
  @moduledoc """
  Typed deep-linking request derived from validated launch claims.
  """

  alias Lti_1p3.Tool.DeepLinking.Settings

  @enforce_keys [:issuer, :audience, :subject, :nonce, :version, :message_type, :roles, :settings]
  defstruct [
    :issuer,
    :audience,
    :subject,
    :nonce,
    :version,
    :message_type,
    :roles,
    :settings,
    :claims
  ]

  @type t() :: %__MODULE__{
          issuer: String.t(),
          audience: String.t() | [String.t()],
          subject: String.t(),
          nonce: String.t(),
          version: String.t(),
          message_type: String.t(),
          roles: [String.t()],
          settings: Settings.t(),
          claims: map()
        }
end
