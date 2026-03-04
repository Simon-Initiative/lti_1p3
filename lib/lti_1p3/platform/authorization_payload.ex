defmodule Lti_1p3.Platform.AuthorizationPayload do
  @moduledoc """
  Normalized authorization redirect payload returned by platform APIs.
  """

  @enforce_keys [:redirect_uri, :state, :id_token]
  defstruct [:redirect_uri, :state, :id_token]

  @type t() :: %__MODULE__{
          redirect_uri: String.t(),
          state: String.t(),
          id_token: String.t()
        }
end
