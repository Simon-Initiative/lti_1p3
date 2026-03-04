defmodule Lti_1p3.Tool.Launch do
  @moduledoc """
  Normalized tool launch payload returned by `Lti_1p3.Tool.validate_launch/3`.
  """

  @enforce_keys [:registration, :claims, :message_type, :deployment_id]
  defstruct [:registration, :claims, :message_type, :deployment_id, :raw_claims]

  @type t() :: %__MODULE__{
          registration: map(),
          claims: map(),
          message_type: String.t(),
          deployment_id: String.t(),
          raw_claims: map() | nil
        }

  @spec new(map(), map(), keyword()) :: t()
  def new(registration, claims, opts \\ []) do
    include_raw_claims = Keyword.get(opts, :raw_claims, false)

    %__MODULE__{
      registration: registration,
      claims: claims,
      message_type: claims["https://purl.imsglobal.org/spec/lti/claim/message_type"],
      deployment_id: claims["https://purl.imsglobal.org/spec/lti/claim/deployment_id"],
      raw_claims: if(include_raw_claims, do: claims, else: nil)
    }
  end
end
