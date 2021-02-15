defmodule Lti_1p3.DataProviders.MemoryProvider do
  use GenServer

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

  @impl GenServer
  def init(_opts \\ []) do
    initial_state = %{
      index_counters: %{},
      jwks: [],
      nonces: %{},
      registrations: %{},
      deployments: [],
      lti_params: %{},
      platform_instances: %{},
      login_hints: %{},
    }

    {:ok, initial_state}
  end

  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  defp get_next_index(type) do
    next_index = Agent.get(__MODULE__, fn state ->
      state.index_counters
      |> Map.get(type, 0)
    end)

    Agent.update(__MODULE__, fn state ->
      %{state | index_counters: state.index_counters |> Map.put(type, next_index + 1)}
    end)

    next_index
  end

  ## DataProviders ##
  @behaviour DataProvider

  @impl DataProvider
  def create_jwk(%Jwk{} = jwk) do
    jwk = jwk |> Map.put(:id, get_next_index(:jwk))
    Agent.update(__MODULE__, fn state ->
      %{state | jwks: state.jwks ++ [jwk]}
    end)

    {:ok, jwk}
  end

  @impl DataProvider
  def get_active_jwk() do
    active_jwk = Agent.get(__MODULE__, fn state ->
      state
      |> Map.get(:jwks)
      |> Enum.find(fn jwk -> jwk.active == true end)
    end)

    case active_jwk do
      nil ->
        {:error, %DataProviderError{msg: "No active Jwk", reason: :not_found}}

      active_jwk ->
        {:ok, active_jwk}
    end
  end

  @impl DataProvider
  def get_all_jwks() do
    Agent.get(__MODULE__, fn state ->
      state
      |> Map.get(:jwks)
    end)
  end

  @impl DataProvider
  def create_nonce(%Nonce{} = nonce) do
    nonce = nonce
      |> Map.from_struct()
      |> Map.put(:inserted_at, Timex.now())
      |> Map.put(:id, get_next_index(:nonce))

    case get_nonce(nonce.value, nonce.domain) do
      nil ->
        Agent.update(__MODULE__, fn state ->
          %{state | nonces: state.nonces |> Map.put_new(nonce_key(nonce), nonce)}
        end)

        {:ok, struct(Nonce, nonce)}
      _ ->
        {:error, %Lti_1p3.DataProviderError{msg: "Nonce with value already exists", reason: :unique_constraint_violation}}
    end
  end

  @impl DataProvider
  def get_nonce(value, domain \\ nil) do
    Agent.get(__MODULE__, fn state ->
      state
      |> Map.get(:nonces)
      |> Map.get(nonce_key(%{value: value, domain: domain}))
      |> case do
        nil ->
          nil
        nonce ->
          struct(Nonce, nonce)
      end
    end)
  end

  def nonce_key(%{value: value, domain: domain}) do
    case domain do
      nil ->
        value
      domain ->
        value <> domain
    end
  end

  # 86400 seconds = 24 hours
  @impl DataProvider
  def delete_expired_nonces(nonce_ttl_sec \\ 86_400) do
    nonce_expiry = Timex.now |> Timex.subtract(Timex.Duration.from_seconds(nonce_ttl_sec))

    Agent.update(__MODULE__, fn state ->
      %{state | nonces: state.nonces
        |> Enum.reduce(%{}, fn {key, nonce}, acc ->
          if nonce.inserted_at > nonce_expiry do
            Map.put(acc, key, nonce)
          else
            acc
          end
        end)
      }
    end)
  end

  ## ToolDataProviders ##
  @behaviour ToolDataProvider

  @doc """
    iex> create_registration(%Registration{})
    {:ok, %Registration{}}
    iex> create_registration(%Registration{})
    {:error, Lti_1p3.DataProviderError.t()}
  """
  @impl ToolDataProvider
  def create_registration(%Registration{issuer: issuer, client_id: client_id} = registration) do
    registration = registration
      |> Map.put(:id, get_next_index(:registration))

    Agent.update(__MODULE__, fn state ->
      %{state | registrations: state.registrations |> Map.put(registration_key(issuer, client_id), registration)}
    end)

    {:ok, registration}
  end

  @impl ToolDataProvider
  def create_deployment(%Deployment{} = deployment) do
    deployment = deployment
      |> Map.put(:id, get_next_index(:deployment))

    Agent.update(__MODULE__, fn state ->
      %{state | deployments: state.deployments ++ [deployment]}
    end)

    {:ok, deployment}
  end

  @impl ToolDataProvider
  def get_rd_by_deployment_id(deployment_id) do
    deployment = Agent.get(__MODULE__, fn state ->
      state.deployments
      |> Enum.find(fn d -> d.deployment_id == deployment_id end)
    end)
    registration = case deployment do
      nil ->
        nil
      deployment ->
        Agent.get(__MODULE__, fn state ->
          state.registrations
          |> Enum.find(fn {_k, r} -> r.id == deployment.registration_id end)
        end)
    end

    {registration, deployment}
  end

  @impl ToolDataProvider
  def get_jwk_by_registration(%Registration{tool_jwk_id: tool_jwk_id}) do
    Agent.get(__MODULE__, fn state ->
      state.jwks
      |> Enum.find(fn jwk -> jwk.id == tool_jwk_id end)
    end)
  end
\
  @impl ToolDataProvider
  def get_registration_by_issuer_client_id(issuer, client_id) do
    Agent.get(__MODULE__, fn state ->
      state.registrations
      |> Map.get(registration_key(issuer, client_id))
    end)
  end

  defp registration_key(issuer, client_id) do
    issuer <> client_id
  end

  @impl ToolDataProvider
  def get_deployment(%Registration{id: registration_id}, deployment_id) do
    Agent.get(__MODULE__, fn state ->
      state.deployments
      |> Enum.find(fn d -> d.registration_id == registration_id && d.deployment_id == deployment_id end)
    end)
  end

  @impl ToolDataProvider
  def get_lti_params_by_sub(sub) do
    Agent.get(__MODULE__, fn state ->
      state.lti_params
      |> Map.get(sub)
    end)
  end

  @impl ToolDataProvider
  def create_or_update_lti_params(%LtiParams{sub: sub} = lti_params) do
    lti_params = lti_params
      |> Map.put(:id, get_next_index(:lti_params))

    Agent.update(__MODULE__, fn state ->
      %{state | lti_params: state.lti_params |> Map.put(sub, lti_params)}
    end)

    {:ok, lti_params}
  end


  ## PlatformDataProviders ##
  @behaviour PlatformDataProvider

  @impl PlatformDataProvider
  def create_platform_instance(%PlatformInstance{client_id: client_id} = platform_instance) do
    platform_instance = platform_instance
      |> Map.put(:id, get_next_index(:platform_instance))

    Agent.update(__MODULE__, fn state ->
      %{state | platform_instances: state.platform_instances |> Map.put_new(client_id, platform_instance)}
    end)

    {:ok, platform_instance}
  end

  @impl PlatformDataProvider
  def get_platform_instance_by_client_id(client_id) do
    Agent.get(__MODULE__, fn state ->
      state.platform_instances
      |> Map.get(client_id)
    end)
  end

  @impl PlatformDataProvider
  def get_login_hint_by_value(value) do
    Agent.get(__MODULE__, fn state ->
      state.login_hints
      |> Map.get(value)
    end)
  end

  @impl PlatformDataProvider
  def create_login_hint(%LoginHint{value: value} = login_hint) do
    login_hint = login_hint
      |> Map.put(:id, get_next_index(:login_hint))

    Agent.update(__MODULE__, fn state ->
      %{state | login_hints: state.login_hints |> Map.put_new(value, login_hint)}
    end)

    {:ok, login_hint}
  end

  # 86400 seconds = 24 hours
  @impl PlatformDataProvider
  def delete_expired_login_hints(login_hint_ttl_sec \\ 86_400) do
    login_hint_expiry = Timex.now |> Timex.subtract(Timex.Duration.from_seconds(login_hint_ttl_sec))

    Agent.update(__MODULE__, fn state ->
      %{state | login_hints: state.login_hints
        |> Enum.reduce(%{}, fn {key, login_hint}, acc ->
          if login_hint.inserted_at > login_hint_expiry do
            Map.put(acc, key, login_hint)
          else
            acc
          end
        end)
      }
    end)
  end
end
