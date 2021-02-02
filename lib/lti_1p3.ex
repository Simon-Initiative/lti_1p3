defmodule Lti_1p3 do
  import Ecto.Query, warn: false
  import Lti_1p3.Config

  alias Lti_1p3.Registration
  alias Lti_1p3.Deployment
  alias Lti_1p3.Jwk

  def get_deployment_id_from_launch(lti_params) do
    Map.get(lti_params, "https://purl.imsglobal.org/spec/lti/claim/deployment_id")
  end

  def create_new_registration(attrs) do
    %Registration{}
    |> Registration.changeset(attrs)
    |> repo!().insert()
  end

  def create_new_deployment(attrs) do
    %Deployment{}
    |> Deployment.changeset(attrs)
    |> repo!().insert()
  end

  def get_deployment(registration, deployment_id) do
    registration_id = registration.id
    repo!().one(from r in Deployment, where: r.registration_id == ^registration_id and r.deployment_id == ^deployment_id)
  end

  def create_new_jwk(attrs) do
    %Jwk{}
    |> Jwk.changeset(attrs)
    |> repo!().insert()
  end

  def get_active_jwk(), do: Lti_1p3.Utils.get_active_jwk()

  def get_all_jwks() do
    repo!().all(from k in Jwk, where: k.active == true)
  end

  def get_rd_by_deployment_id(deployment_id) do
    repo!().one from registration in Registration,
      join: deployment in Deployment, on: deployment.registration_id == registration.id,
      where: deployment.deployment_id == ^deployment_id,
      select: {registration, deployment}
  end

  @doc """
  Returns lti_1p3 deployment if a record matches deployment_id, or creates and returns a new deployment

  ## Examples

      iex> Lti_1p3.insert_or_update_lti_1p3_deployment(%{deployment_id: "some-deployment-id"})
      {:ok, %Lti_1p3.Deployment{}}    -> # Inserted or updated with success
      {:error, changeset}             -> # Something went wrong

  """
  def insert_or_update_lti_1p3_deployment(%{deployment_id: deployment_id} = changes) do
    case repo!().get_by(Lti_1p3.Deployment, deployment_id: deployment_id) do
      nil -> %Lti_1p3.Deployment{}
      deployment -> deployment
    end
    |> Lti_1p3.Deployment.changeset(changes)
    |> repo!().insert_or_update
  end

  @doc """
  Caches LTI 1.3 params map using the given key. Assumes lti_params contains standard LTI fields
  including "exp" for expiration date
  ## Examples
      iex> cache_lti_params!(key, lti_params)
      %Lti_1p3.LtiParams{}
  """
  def cache_lti_params!(key, lti_params) do
    exp = Timex.from_unix(lti_params["exp"])

    case repo!().get_by(Lti_1p3.LtiParams, key: key) do
      nil  -> %Lti_1p3.LtiParams{}
      lti_params -> lti_params
    end
    |> Lti_1p3.LtiParams.changeset(%{key: key, data: lti_params, exp: exp})
    |> repo!().insert_or_update!()
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
  def fetch_lti_params(key), do: repo!().get_by(Lti_1p3.LtiParams, key: key)

end
