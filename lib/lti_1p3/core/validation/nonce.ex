defmodule Lti_1p3.Core.Validation.Nonce do
  @moduledoc """
  Nonce uniqueness validation.
  """

  alias Lti_1p3.Core.Errors

  @spec validate(map(), String.t()) :: :ok | {:error, Errors.t()}
  def validate(claims, domain) do
    case Lti_1p3.Nonces.create_nonce(claims["nonce"], domain) do
      {:ok, _nonce} ->
        :ok

      {:error, %Lti_1p3.DataProviderError{reason: :unique_constraint_violation}} ->
        Errors.error(:nonce, :invalid_nonce, "Duplicate nonce")

      {:error, %Lti_1p3.DataProviderError{msg: msg}} ->
        Errors.error(:nonce, :invalid_nonce, msg)
    end
  end
end
