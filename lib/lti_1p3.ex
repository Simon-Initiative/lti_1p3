defmodule Lti_1p3 do
  @moduledoc """

  """
  import Lti_1p3.Config

  @doc """
  Gets the currently active Jwk.
  If there are more that one active Jwk, this will return the first one it finds
  ## Examples
      iex> get_active_jwk()
      {:ok, %Lti_1p3.Jwk{}}
      iex> get_active_jwk()
      {:error, %Lti_1p3.DataProviderError{}}
  """
  def get_active_jwk(), do: provider!().get_active_jwk()

  @doc """
  Gets a all public keys
  ## Examples
      iex> get_all_public_keys()
      %{keys: []}
  """
  def get_all_public_keys() do
    public_keys = provider!().get_all_jwks()
      |> Enum.map(fn %{pem: pem, typ: typ, alg: alg, kid: kid} ->
        pem
        |> JOSE.JWK.from_pem
        |> JOSE.JWK.to_public
        |> JOSE.JWK.to_map()
        |> (fn {_kty, public_jwk} -> public_jwk end).()
        |> Map.put("typ", typ)
        |> Map.put("alg", alg)
        |> Map.put("kid", kid)
        |> Map.put("use", "sig")
      end)

    %{keys: public_keys}
  end

end
