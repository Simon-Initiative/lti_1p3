defmodule Lti_1p3.Tool.DeepLinking.Settings do
  @moduledoc """
  Typed deep-linking settings parsed from launch claims.
  """

  alias Lti_1p3.Tool.DeepLinking.Errors

  @enforce_keys [:deep_link_return_url, :accept_types, :accept_presentation_document_targets]
  defstruct [
    :deep_link_return_url,
    :accept_types,
    :accept_presentation_document_targets,
    :accept_media_types,
    :accept_multiple,
    :accept_lineitem,
    :auto_create,
    :title,
    :text,
    :data
  ]

  @type t() :: %__MODULE__{
          deep_link_return_url: String.t(),
          accept_types: [String.t()],
          accept_presentation_document_targets: [String.t()],
          accept_media_types: String.t() | nil,
          accept_multiple: boolean() | nil,
          accept_lineitem: boolean() | nil,
          auto_create: boolean() | nil,
          title: String.t() | nil,
          text: String.t() | nil,
          data: any() | nil
        }

  @spec parse(map()) :: {:ok, t()} | {:error, Errors.t()}
  def parse(%{} = settings_claim) do
    with {:ok, deep_link_return_url} <-
           fetch_required_string(settings_claim, "deep_link_return_url"),
         {:ok, accept_types} <- fetch_required_string_list(settings_claim, "accept_types"),
         {:ok, accept_targets} <-
           fetch_required_string_list(settings_claim, "accept_presentation_document_targets") do
      {:ok,
       %__MODULE__{
         deep_link_return_url: deep_link_return_url,
         accept_types: accept_types,
         accept_presentation_document_targets: accept_targets,
         accept_media_types: fetch_optional_string(settings_claim, "accept_media_types"),
         accept_multiple: fetch_optional_boolean(settings_claim, "accept_multiple"),
         accept_lineitem: fetch_optional_boolean(settings_claim, "accept_lineitem"),
         auto_create: fetch_optional_boolean(settings_claim, "auto_create"),
         title: fetch_optional_string(settings_claim, "title"),
         text: fetch_optional_string(settings_claim, "text"),
         data: Map.get(settings_claim, "data")
       }}
    end
  end

  def parse(_value) do
    Errors.error(
      :request,
      :invalid_deep_linking_settings,
      "Deep linking settings claim must be a map"
    )
  end

  defp fetch_required_string(map, key) do
    case Map.get(map, key) do
      value when is_binary(value) and value != "" -> {:ok, value}
      _ -> Errors.error(:request, :invalid_deep_linking_settings, "Missing or invalid #{key}")
    end
  end

  defp fetch_required_string_list(map, key) do
    case Map.get(map, key) do
      values when is_list(values) ->
        values
        |> Enum.filter(&(is_binary(&1) and &1 != ""))
        |> case do
          [] ->
            Errors.error(:request, :invalid_deep_linking_settings, "Missing or invalid #{key}")

          valid_values ->
            {:ok, valid_values}
        end

      _ ->
        Errors.error(:request, :invalid_deep_linking_settings, "Missing or invalid #{key}")
    end
  end

  defp fetch_optional_string(map, key) do
    case Map.get(map, key) do
      value when is_binary(value) and value != "" -> value
      _ -> nil
    end
  end

  defp fetch_optional_boolean(map, key) do
    case Map.get(map, key) do
      value when is_boolean(value) -> value
      _ -> nil
    end
  end
end
