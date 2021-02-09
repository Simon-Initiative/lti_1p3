defmodule Lti_1p3.Platform.PlatformInstance do
  @enforce_keys [:name, :target_link_uri, :client_id, :login_url, :keyset_url, :redirect_uris]
  defstruct [:id, :name, :description, :target_link_uri, :client_id, :login_url, :keyset_url, :redirect_uris, :custom_params]

  @type t() :: %__MODULE__{
    id: integer(),
    client_id: String.t(),
    custom_params: String.t(),
    description: String.t(),
    keyset_url: String.t(),
    login_url: String.t(),
    name: String.t(),
    redirect_uris: String.t(),
    target_link_uri: String.t(),
  }

  def from(attrs) do
    struct(Lti_1p3.Platform.PlatformInstance, attrs)
  end

  def to_map(%Lti_1p3.Platform.PlatformInstance{} = platform_instance) do
    platform_instance
    |> Map.from_struct()
    |> Map.take(Lti_1p3.Platform.PlatformInstance.__struct__() |> Map.keys())
  end
end
