defmodule Lti_1p3.LaunchValidation do
  import Lti_1p3.Utils

  @message_validators [
    Lti_1p3.MessageValidators.ResourceMessageValidator
  ]

  @type params() :: %{state: binary(), id_token: binary()}
  @type validate_opts() :: []

  @doc """
  Validates an incoming LTI 1.3 launch and caches the launch params in the session if successful.
  """
  @spec validate(params(), validate_opts()) :: {:ok, any(), binary()} | {:error, %{optional(atom()) => any(), reason: atom(), msg: String.t()}}
  def validate(params, session_state, _opts \\ []) do
    with {:ok} <- validate_oidc_state(params, session_state),
         {:ok, registration} <- validate_registration(params),
         {:ok, key_set_url} <- registration_key_set_url(registration),
         {:ok, id_token} <- extract_param(params, "id_token"),
         {:ok, jwt_body} <- validate_jwt_signature(id_token, key_set_url),
         {:ok} <- validate_timestamps(jwt_body),
         {:ok} <- validate_deployment(registration, jwt_body),
         {:ok} <- validate_message(jwt_body),
         {:ok} <- validate_nonce(jwt_body, "validate_launch"),
         {:ok, cache_key} <- cache_launch_params(jwt_body)
    do
      {:ok, jwt_body, cache_key}
    end
  end

  # Validate that the state sent with an OIDC launch matches the state that was sent in the OIDC response
  # returns a boolean on whether it is valid or not
  defp validate_oidc_state(params, session_state) do
    case session_state do
      nil ->
        {:error, %{reason: :invalid_oidc_state, msg: "State from session is missing. Make sure cookies are enabled and configured correctly"}}
      session_state ->
        case params["state"] do
          nil ->
            {:error, %{reason: :invalid_oidc_state, msg: "State from OIDC request is missing"}}
          request_state ->
            if request_state == session_state do
              {:ok}
            else
              {:error, %{reason: :invalid_oidc_state, msg: "State from OIDC request does not match session"}}
            end
        end
    end
  end

  defp validate_registration(params) do
    with {:ok, issuer, client_id} <- peek_issuer_client_id(params) do
      case get_registration_by_issuer_client_id(issuer, client_id) do
        nil ->
          {:error, %{reason: :invalid_registration, msg: "Registration with issuer \"#{issuer}\" and client id \"#{client_id}\" not found", issuer: issuer, client_id: client_id}}
        registration ->
          {:ok, registration}
      end
    end
  end

  defp peek_issuer_client_id(params) do
    with {:ok, jwt_string} <- extract_param(params, "id_token"),
         {:ok, jwt_claims} <- peek_claims(jwt_string)
    do
      {:ok, jwt_claims["iss"], jwt_claims["aud"]}
    end
  end

  defp validate_deployment(registration, jwt_body) do
    deployment_id = jwt_body["https://purl.imsglobal.org/spec/lti/claim/deployment_id"]
    deployment = Lti_1p3.get_deployment(registration, deployment_id)

    case deployment do
      nil ->
        {:error, %{reason: :invalid_deployment, msg: "Deployment with id \"#{deployment_id}\" not found", registration_id: registration.id, deployment_id: deployment_id}}
      _deployment ->
        {:ok}
    end
  end

  defp validate_message(jwt_body) do
    case jwt_body["https://purl.imsglobal.org/spec/lti/claim/message_type"] do
      nil ->
        {:error, %{reason: :invalid_message_type, msg: "Missing message type"}}
      message_type ->
        # no more than one message validator should apply for a given mesage,
        # so use the first validator we find that applies
        validation_result = case Enum.find(@message_validators, fn mv -> mv.can_validate(jwt_body) end) do
          nil -> nil
          validator -> validator.validate(jwt_body)
        end

        case validation_result do
          nil ->
            {:error, %{reason: :invalid_message_type, msg: "Invalid or unsupported message type \"#{message_type}\""}}
          {:error, error} ->
            {:error, %{reason: :invalid_message, msg: "Message validation failed: (\"#{message_type}\") #{error}"}}
          _ ->
            {:ok}
        end
    end
  end

  defp cache_launch_params(lti_params) do
    # LTI 1.3 params are too big to store in the session cookie. Therefore, we must
    # cache all lti_params key'd off the sub value in database for use in other views
    cache_key = lti_params["sub"]
    Lti_1p3.cache_lti_params!(cache_key, lti_params)

    {:ok, cache_key}
  end

end
