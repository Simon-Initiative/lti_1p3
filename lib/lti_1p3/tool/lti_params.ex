defmodule Lti_1p3.Tool.LtiParams do
  import Lti_1p3.Config
  alias Lti_1p3.Tool.LtiParams

  @enforce_keys [:key, :data, :exp]
  defstruct [:id, :key, :data, :exp]

  @type t() :: %__MODULE__{
    id: integer(),
    key: String.t(),
    data: map(),
    exp: DateTime.t()
  }

  @doc """
  Caches LTI 1.3 params map using the given key. Assumes lti_params contains standard LTI fields
  including "exp" for expiration date
  ## Examples
      iex> Lti_1p3.cache_lti_params("some-key", %{"some" => "param"})
      {:ok, %Lti_1p3.LtiParams{}}
      iex> Lti_1p3.cache_lti_params("some-key", %{"invalid" => "param"})
      {:error, Ecto.Changeset.t()}
  """
  def cache_lti_params(key, lti_params) do
    exp = Timex.from_unix(lti_params["exp"])

    %LtiParams{key: key, data: lti_params, exp: exp}
    |> provider!().create_or_update_lti_params()
  end

  @doc """
  Gets a user's cached lti_params from the database using the given key.
  Returns `nil` if the lti_params do not exist.
  ## Examples
      iex> Lti_1p3.fetch_lti_params("some-key")
      %Lti_1p3.LtiParams{}
      iex> Lti_1p3.fetch_lti_params("bad-key")
      nil
  """
  def fetch_lti_params(key), do: provider!().get_lti_params_by_key(key)

end
