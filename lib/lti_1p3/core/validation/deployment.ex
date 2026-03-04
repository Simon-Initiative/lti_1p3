defmodule Lti_1p3.Core.Validation.Deployment do
  @moduledoc """
  Deployment validation for launch claims.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Core.Errors

  @deployment_claim "https://purl.imsglobal.org/spec/lti/claim/deployment_id"

  @spec validate(map(), map()) :: {:ok, String.t()} | {:error, Errors.t()}
  def validate(registration, claims) do
    deployment_id = Map.get(claims, @deployment_claim)

    case provider!().get_deployment(registration, deployment_id) do
      nil ->
        Errors.error(
          :deployment,
          :invalid_deployment,
          "Deployment with id \"#{deployment_id}\" not found",
          %{registration_id: registration.id, deployment_id: deployment_id}
        )

      _deployment ->
        {:ok, deployment_id}
    end
  end
end
