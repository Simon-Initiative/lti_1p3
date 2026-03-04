defmodule Lti_1p3.Core.Validation.State do
  @moduledoc """
  OIDC state validation.
  """

  alias Lti_1p3.Core.Errors

  @spec validate(String.t() | nil, String.t() | nil) :: :ok | {:error, Errors.t()}
  def validate(nil, _request_state) do
    Errors.error(
      :state,
      :invalid_oidc_state,
      "State from session is missing. Make sure cookies are enabled and configured correctly"
    )
  end

  def validate(_session_state, nil) do
    Errors.error(:state, :invalid_oidc_state, "State from OIDC request is missing")
  end

  def validate(session_state, request_state) when session_state == request_state, do: :ok

  def validate(_session_state, _request_state) do
    Errors.error(:state, :invalid_oidc_state, "State from OIDC request does not match session")
  end
end
