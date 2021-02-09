defmodule Lti_1p3.DataProviders.EctoProvider do
  import Ecto.Query, warn: false
  import Lti_1p3.DataProviders.EctoProvider.Config

  alias Lti_1p3.DataProvider
  alias Lti_1p3.PlatformDataProvider
  alias Lti_1p3.ToolDataProvider
  alias Lti_1p3.DataProviderError
  alias Lti_1p3.Jwk
  alias Lti_1p3.Nonce
  alias Lti_1p3.Tool.Registration
  alias Lti_1p3.Tool.Deployment
  alias Lti_1p3.Tool.LtiParams
  alias Lti_1p3.Platform.PlatformInstance
  alias Lti_1p3.Platform.LoginHint

  ## DataProviders ##
  @behaviour DataProvider

  @impl DataProvider
  def create_jwk(%Jwk{} = jwk) do
    attrs = marshal_from(jwk, Jwk)

    struct(schema(:jwk))
    |> schema(:jwk).changeset(attrs)
    |> repo!().insert()
    |> unmarshal_to(Jwk)
  end

  @impl DataProvider
  def get_active_jwk() do
    case repo!().all(from k in schema(:jwk), where: k.active == true, order_by: [desc: k.id], limit: 1) do
      [head | _] -> {:ok, unmarshal_to(head, Jwk)}
      _ -> {:error, %Lti_1p3.DataProviderError{msg: "No active Jwk found", reason: :not_found}}
    end
  end

  @impl DataProvider
  def get_nonce(id), do: repo!().get(schema(:nonce), id)
    |> unmarshal_to(Nonce)

  @impl DataProvider
  def create_nonce(%Nonce{} = nonce) do
    attrs = marshal_from(nonce, Nonce)

    struct(schema(:nonce))
    |> schema(:nonce).changeset(attrs)
    |> repo!().insert()
    |> case do
      {:error, %Ecto.Changeset{ errors: [ value: { _msg, [{:constraint, :unique} | _]}]} = changeset} ->
        {:error, %Lti_1p3.DataProviderError{msg: maybe_changeset_error_to_str(changeset), reason: :unique_constraint_violation}}
      nonce ->
        unmarshal_to(nonce, Nonce)
    end
  end

  @impl DataProvider
  def delete_expired_nonces(nonce_expiry) do
    repo!().delete_all from(n in schema(:nonce), where: n.inserted_at < ^nonce_expiry)
  end

  ## ToolDataProviders ##
  @behaviour ToolDataProvider

  @impl ToolDataProvider
  def create_registration(%Registration{} = registration) do
    attrs = marshal_from(registration, Registration)

    struct(schema(:registration))
    |> schema(:registration).changeset(attrs)
    |> repo!().insert()
    |> unmarshal_to(Registration)
  end

  @impl ToolDataProvider
  def create_deployment(%Deployment{} = deployment) do
    attrs = marshal_from(deployment, Deployment)

    struct(schema(:deployment))
    |> schema(:deployment).changeset(attrs)
    |> repo!().insert()
    |> unmarshal_to(Deployment)
  end

  @impl ToolDataProvider
  def get_rd_by_deployment_id(deployment_id) do
    case repo!().one from d in schema(:deployment),
      join: r in ^schema(:registration), on: d.registration_id == r.id,
      where: d.deployment_id == ^deployment_id,
      select: {r, d} do
      nil ->
        nil
      {r, d} ->
        {unmarshal_to(r, Registration), unmarshal_to(d, Deployment)}
    end
  end

  @impl ToolDataProvider
  def get_jwk_by_registration(%Registration{id: registration_id}) do
    repo!().one(from r in schema(:registration),
      join: jwk in assoc(r, :tool_jwk),
      where: r.id == ^registration_id,
      select: jwk)
    |> unmarshal_to(Jwk)
  end

  @impl ToolDataProvider
  def get_registration_by_issuer_client_id(issuer, client_id) do
    repo!().one(from registration in schema(:registration),
      where: registration.issuer == ^ issuer and registration.client_id == ^client_id,
      select: registration)
    |> unmarshal_to(Registration)
  end

  @impl ToolDataProvider
  def get_deployment(%Registration{id: registration_id}, deployment_id) do
    repo!().one(from r in schema(:deployment),
      # where: r.registration_id == ^registration_id and r.deployment_id == ^deployment_id,
      # preload: [:registration])
      where: r.registration_id == ^registration_id and r.deployment_id == ^deployment_id)
    |> unmarshal_to(Deployment)
  end

  @impl ToolDataProvider
  def get_lti_params_by_key(key), do: repo!().get_by(schema(:lti_params), key: key)
    |> unmarshal_to(LtiParams)

  @impl ToolDataProvider
  def create_or_update_lti_params(%LtiParams{} = lti_params) do
    attrs = marshal_from(lti_params, LtiParams)

    struct(schema(:lti_params))
    |> schema(:lti_params).changeset(attrs)
    |> repo!().insert_or_update()
    |> unmarshal_to(LtiParams)
  end

  ## PlatformDataProviders ##
  @behaviour PlatformDataProvider

  @impl PlatformDataProvider
  def create_platform_instance(%PlatformInstance{} = platform_instance) do
    attrs = marshal_from(platform_instance, PlatformInstance)

    struct(schema(:platform_instance))
    |> schema(:platform_instance).changeset(attrs)
    |> repo!().insert()
    |> unmarshal_to(PlatformInstance)
  end

  @impl PlatformDataProvider
  def get_platform_instance_by_client_id(client_id), do: repo!().get_by(schema(:platform_instance), client_id: client_id)
    |> unmarshal_to(PlatformInstance)

  @impl PlatformDataProvider
  def get_login_hint_by_value(value), do: repo!().get_by(schema(:login_hint), value: value)
    |> unmarshal_to(LoginHint)

  @impl PlatformDataProvider
  def create_login_hint(%LoginHint{} = login_hint) do
    attrs = marshal_from(login_hint, LoginHint)

    struct(schema(:login_hint))
    |> schema(:login_hint).changeset(attrs)
    |> repo!().insert()
    |> unmarshal_to(LoginHint)
  end

  @impl PlatformDataProvider
  def delete_expired_login_hints(login_hint_expiry) do
    repo!().delete_all from(h in schema(:login_hint), where: h.inserted_at < ^login_hint_expiry)
  end

  defp marshal_from(data, struct_type, additional_attrs \\ %{}) do
    struct_type.to_map(data)
    |> Map.merge(additional_attrs)
  end

  defp unmarshal_to({:ok, data}, struct_type) do
    map = Map.from_struct(data)
    {:ok, struct_type.from(map)}
  end

  defp unmarshal_to({:error, maybe_changeset}, _struct_type) do
    {:error, %DataProviderError{msg: maybe_changeset_error_to_str(maybe_changeset)}}
  end

  defp unmarshal_to(nil, _struct_type) do
    nil
  end

  defp unmarshal_to(data, struct_type) do
    map = Map.from_struct(data)
    struct_type.from(map)
  end

  defp maybe_changeset_error_to_str(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", _to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      "#{acc} #{k}: #{joined_errors}"
    end)
    |> String.trim()
  end
  defp maybe_changeset_error_to_str(no_changeset), do: no_changeset

  defp _to_string(val) when is_list(val) do
    Enum.join(val, ",")
  end
  defp _to_string(val), do: to_string(val)

end
