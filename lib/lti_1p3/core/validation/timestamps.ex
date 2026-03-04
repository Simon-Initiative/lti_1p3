defmodule Lti_1p3.Core.Validation.Timestamps do
  @moduledoc """
  JWT exp/iat validation with skew tolerance.
  """

  alias Lti_1p3.Core.Errors

  @spec validate(map(), keyword()) :: :ok | {:error, Errors.t()}
  def validate(claims, opts \\ []) do
    skew_seconds = Keyword.get(opts, :clock_skew_seconds, 5)

    with {:ok, exp} <- unix_claim(claims, "exp"),
         {:ok, iat} <- unix_claim(claims, "iat") do
      now = DateTime.utc_now() |> DateTime.to_unix()

      expired? = exp < now - skew_seconds
      iat_in_future? = iat > now + skew_seconds

      case {expired?, iat_in_future?} do
        {false, false} ->
          :ok

        {true, false} ->
          Errors.error(:timestamps, :invalid_jwt_timestamp, "JWT exp is expired")

        {false, true} ->
          Errors.error(:timestamps, :invalid_jwt_timestamp, "JWT iat is invalid")

        {true, true} ->
          Errors.error(:timestamps, :invalid_jwt_timestamp, "JWT exp and iat are invalid")
      end
    end
  end

  defp unix_claim(claims, key) do
    case Map.get(claims, key) do
      value when is_integer(value) -> {:ok, value}
      _ -> Errors.error(:timestamps, :invalid_jwt_timestamp, "Timestamps are invalid")
    end
  end
end
