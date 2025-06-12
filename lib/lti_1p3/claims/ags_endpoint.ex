defmodule Lti_1p3.Claims.AgsEndpoint do
  @moduledoc """
  A struct representing the LTI AGS endpoint claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti-ags/v2p0/#assignment-and-grade-service-claim
  """
  @enforce_keys [:scope]

  defstruct [
    :scope,
    :lineitems,
    :lineitem
  ]

  @type t() :: %__MODULE__{
          scope: list(String.t()),
          lineitems: String.t(),
          lineitem: String.t()
        }

  def key, do: "https://purl.imsglobal.org/spec/lti-ags/claim/endpoint"

  @doc """
  Create a new AGS endpoint claim.
  """
  def endpoint(scope, opts \\ []) do
    %__MODULE__{
      scope: scope,
      lineitems: Keyword.get(opts, :lineitems),
      lineitem: Keyword.get(opts, :lineitem)
    }
  end
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.AgsEndpoint do
  def get_key(_), do: Lti_1p3.Claims.AgsEndpoint.key()

  def get_value(%Lti_1p3.Claims.AgsEndpoint{
        scope: scope,
        lineitems: lineitems,
        lineitem: lineitem
      }) do
    %{
      "scope" => scope,
      "lineitems" => lineitems,
      "lineitem" => lineitem
    }
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end
end
