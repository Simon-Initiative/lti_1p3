defmodule Lti_1p3.Claims.PlatformInstance do
  @moduledoc """
  A struct representing the platform instance claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#platform-instance-claim
  """
  @enforce_keys [:guid]

  defstruct [
    :guid,
    :contact_email,
    :description,
    :name,
    :url,
    :product_family_code,
    :version
  ]

  @type t() :: %__MODULE__{
          guid: String.t(),
          contact_email: String.t(),
          description: String.t(),
          name: String.t(),
          url: String.t(),
          product_family_code: String.t(),
          version: String.t()
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/tool_platform"

  @doc """
  Create a new platform instance claim.
  """
  def platform_instance(guid, opts \\ []) do
    %__MODULE__{
      guid: guid,
      contact_email: Keyword.get(opts, :contact_email),
      description: Keyword.get(opts, :description),
      name: Keyword.get(opts, :name),
      url: Keyword.get(opts, :url),
      product_family_code: Keyword.get(opts, :product_family_code),
      version: Keyword.get(opts, :version)
    }
  end
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.PlatformInstance do
  def get_key(_), do: Lti_1p3.Claims.PlatformInstance.key()

  def get_value(%Lti_1p3.Claims.PlatformInstance{
        guid: guid,
        contact_email: contact_email,
        description: description,
        name: name,
        url: url,
        product_family_code: product_family_code,
        version: version
      }) do
    %{
      "guid" => guid,
      "contact_email" => contact_email,
      "description" => description,
      "name" => name,
      "url" => url,
      "product_family_code" => product_family_code,
      "version" => version
    }
  end
end
