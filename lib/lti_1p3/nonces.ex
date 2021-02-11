defmodule Lti_1p3.Nonces do
  import Lti_1p3.Config

  alias Lti_1p3.Nonce

  require Logger

  @doc """
  Gets a single nonce.
  Returns nil if the Nonce does not exist.
  ## Examples
      iex> get_nonce(123)
      %Nonce{}
      iex> get_nonce(456)
      nil
  """
  def get_nonce(id), do: provider!().get_nonce(id)

  @doc """
  Creates a nonce. Returns a error if the nonce already exists
  ## Examples
      iex> create_nonce("value", "domain")
      {:ok, %Nonce{}}
      iex> create_nonce("bad value", "domain")
      {:error, %Ecto.Changeset{}}
  """
  def create_nonce(value, domain \\ nil), do: provider!().create_nonce(%Nonce{value: value, domain: domain})

  @doc """
  Removes all nonces older than the configured @max_nonce_ttl_sec value
  """
  def cleanup_nonce_store() do
    Logger.info("Cleaning up expired LTI 1.3 nonces...")

    nonce_ttl_sec = Lti_1p3.Config.get(:nonce_ttl_sec)
    provider!().delete_expired_nonces(nonce_ttl_sec)

    Logger.info("Nonce cleanup complete.")
  end

end
