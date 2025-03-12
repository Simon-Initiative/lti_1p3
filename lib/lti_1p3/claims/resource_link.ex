defmodule Lti_1p3.Claims.ResourceLink do
  @moduledoc """
  A struct representing the resource link claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#resource-link-claim
  """
  @enforce_keys [:id]

  defstruct [
    :id,
    :description,
    :title
  ]

  @type t() :: %__MODULE__{
          id: String.t(),
          description: String.t(),
          title: String.t()
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/resource_link"

  @doc """
  Create a new resource link claim.
  """
  def resource_link(id, opts \\ []) do
    %__MODULE__{
      id: id,
      description: Keyword.get(opts, :description),
      title: Keyword.get(opts, :title)
    }
  end
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.ResourceLink do
  def get_key(_), do: Lti_1p3.Claims.ResourceLink.key()

  def get_value(%Lti_1p3.Claims.ResourceLink{
        id: id,
        description: description,
        title: title
      }) do
    %{
      "id" => id,
      "description" => description,
      "title" => title
    }
  end
end
