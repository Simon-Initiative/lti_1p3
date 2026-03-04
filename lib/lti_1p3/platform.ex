defmodule Lti_1p3.Platform do
  @moduledoc """
  Public API for platform-side LTI 1.3 flows and platform registrations.
  """

  import Lti_1p3.Config

  alias Lti_1p3.Platform.AuthorizationPayload
  alias Lti_1p3.Platform.AuthorizationRedirect

  @type error_map :: %{reason: atom(), stage: atom(), msg: String.t(), details: map()}

  @doc """
  Creates a new platform instance.
  """
  @spec create_platform_instance(Lti_1p3.Platform.PlatformInstance.t()) ::
          {:ok, Lti_1p3.Platform.PlatformInstance.t()} | {:error, Lti_1p3.DataProviderError.t()}
  def create_platform_instance(%Lti_1p3.Platform.PlatformInstance{} = platform_instance),
    do: provider!().create_platform_instance(platform_instance)

  @doc """
  Validates and authorizes a platform redirect request, returning a normalized payload.
  """
  @spec authorize_redirect(map(), map(), String.t(), list(), keyword()) ::
          {:ok, AuthorizationPayload.t()} | {:error, error_map()}
  def authorize_redirect(params, current_user, issuer, claims, opts \\ []) do
    case AuthorizationRedirect.authorize_redirect(params, current_user, issuer, claims, opts) do
      {:ok, redirect_uri, state, id_token} ->
        {:ok, %AuthorizationPayload{redirect_uri: redirect_uri, state: state, id_token: id_token}}

      {:error, error} ->
        {:error, ensure_error_shape(error, :platform_authorize)}
    end
  end

  defp ensure_error_shape(error, stage) do
    error
    |> Map.put_new(:stage, stage)
    |> Map.put_new(:details, %{})
  end
end
