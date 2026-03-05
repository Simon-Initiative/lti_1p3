defmodule Lti_1p3.Tool.Services.NRPS.Endpoint do
  @moduledoc """
  Typed NRPS endpoint configuration parsed from launch claims.
  """

  @enforce_keys [:context_memberships_url, :scopes, :service_versions]
  defstruct [:context_memberships_url, :scopes, :service_versions]

  @type t() :: %__MODULE__{
          context_memberships_url: String.t(),
          scopes: [String.t()],
          service_versions: [String.t()]
        }
end
