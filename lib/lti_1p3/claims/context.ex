defmodule Lti_1p3.Claims.Context do
  @moduledoc """
  A struct representing the context claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#context-claim
  """

  defstruct [
    :label,
    :title,
    :type
  ]

  @type t() :: %__MODULE__{
          label: String.t(),
          title: String.t(),
          type: String.t()
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/context"

  @doc """
  Create a new context claim.
  """
  def context(opts \\ []) do
    %__MODULE__{
      label: Keyword.get(opts, :label),
      title: Keyword.get(opts, :title),
      type: Keyword.get(opts, :type)
    }
  end
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.Context do
  def get_key(_), do: Lti_1p3.Claims.Context.key()

  def get_value(%Lti_1p3.Claims.Context{
        label: label,
        title: title,
        type: type
      }) do
    %{
      "label" => label,
      "title" => title,
      "type" => type
    }
  end
end
