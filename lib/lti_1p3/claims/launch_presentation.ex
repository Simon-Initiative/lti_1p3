defmodule Lti_1p3.Claims.LaunchPresentation do
  @moduledoc """
  A struct representing the launch presentation claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#launch-presentation-claim
  """

  defstruct [
    :document_target,
    :height,
    :width,
    :return_url,
    :locale
  ]

  @type t() :: %__MODULE__{
          document_target: String.t(),
          height: integer(),
          width: integer(),
          return_url: String.t(),
          locale: String.t()
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/launch_presentation"

  @doc """
  Create a new launch presentation claim.
  """
  def launch_presentation(opts \\ []) do
    %__MODULE__{
      document_target: Keyword.get(opts, :document_target),
      height: Keyword.get(opts, :height),
      width: Keyword.get(opts, :width),
      return_url: Keyword.get(opts, :return_url),
      locale: Keyword.get(opts, :locale)
    }
  end
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.LaunchPresentation do
  def get_key(_), do: Lti_1p3.Claims.LaunchPresentation.key()

  def get_value(%Lti_1p3.Claims.LaunchPresentation{
        document_target: document_target,
        height: height,
        width: width,
        return_url: return_url,
        locale: locale
      }) do
    %{
      "document_target" => document_target,
      "height" => height,
      "width" => width,
      "return_url" => return_url,
      "locale" => locale
    }
  end
end
