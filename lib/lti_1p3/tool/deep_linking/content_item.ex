defmodule Lti_1p3.Tool.DeepLinking.ContentItem do
  @moduledoc """
  Typed deep-linking content item builders with subtype validation.
  """

  alias Lti_1p3.Tool.DeepLinking.Errors

  @enforce_keys [:type]
  defstruct [
    :type,
    :url,
    :title,
    :text,
    :html,
    :icon,
    :thumbnail,
    :line_item,
    :iframe,
    :available,
    :custom,
    :embed,
    :window
  ]

  @type t() :: %__MODULE__{
          type: String.t(),
          url: String.t() | nil,
          title: String.t() | nil,
          text: String.t() | nil,
          html: String.t() | nil,
          icon: map() | nil,
          thumbnail: map() | nil,
          line_item: map() | nil,
          iframe: map() | nil,
          available: map() | nil,
          custom: map() | nil,
          embed: map() | nil,
          window: map() | nil
        }

  @supported_types %{
    "ltiResourceLink" => :url_required,
    "link" => :url_required,
    "file" => :url_required,
    "image" => :url_required,
    "html" => :html_required
  }

  @type input_type() :: String.t() | atom()

  def content_item(type, attrs \\ %{})

  @spec content_item(input_type(), map()) :: {:ok, t()} | {:error, Errors.t()}
  def content_item(type, attrs) when is_map(attrs) do
    with {:ok, normalized_type} <- normalize_type(type),
         :ok <- validate_type_specific_requirements(normalized_type, attrs) do
      {:ok,
       %__MODULE__{
         type: normalized_type,
         url: fetch_string(attrs, "url"),
         title: fetch_string(attrs, "title"),
         text: fetch_string(attrs, "text"),
         html: fetch_string(attrs, "html"),
         icon: fetch_map(attrs, "icon"),
         thumbnail: fetch_map(attrs, "thumbnail"),
         line_item: fetch_map(attrs, "lineItem"),
         iframe: fetch_map(attrs, "iframe"),
         available: fetch_map(attrs, "available"),
         custom: fetch_map(attrs, "custom"),
         embed: fetch_map(attrs, "embed"),
         window: fetch_map(attrs, "window")
       }}
    end
  end

  def content_item(_type, _attrs) do
    Errors.error(:content_item, :invalid_content_item, "Content item attrs must be a map")
  end

  @spec to_claim(t()) :: map()
  def to_claim(%__MODULE__{} = item) do
    %{
      "type" => item.type,
      "url" => item.url,
      "title" => item.title,
      "text" => item.text,
      "html" => item.html,
      "icon" => item.icon,
      "thumbnail" => item.thumbnail,
      "lineItem" => item.line_item,
      "iframe" => item.iframe,
      "available" => item.available,
      "custom" => item.custom,
      "embed" => item.embed,
      "window" => item.window
    }
    |> Enum.reduce(%{}, fn
      {_key, nil}, acc -> acc
      {key, value}, acc -> Map.put(acc, key, value)
    end)
  end

  defp normalize_type(type) do
    case type |> to_string() |> String.trim() do
      "lti_resource_link" ->
        {:ok, "ltiResourceLink"}

      "resource_link" ->
        {:ok, "ltiResourceLink"}

      "ltiResourceLink" ->
        {:ok, "ltiResourceLink"}

      "link" ->
        {:ok, "link"}

      "file" ->
        {:ok, "file"}

      "image" ->
        {:ok, "image"}

      "html" ->
        {:ok, "html"}

      unsupported ->
        Errors.error(
          :content_item,
          :unsupported_content_item_type,
          "Unsupported content item type #{unsupported}"
        )
    end
  end

  defp validate_type_specific_requirements(type, attrs) do
    case @supported_types[type] do
      :url_required ->
        if valid_string?(Map.get(attrs, "url")) do
          :ok
        else
          Errors.error(
            :content_item,
            :invalid_content_item,
            "Content item type #{type} requires url",
            %{type: type}
          )
        end

      :html_required ->
        if valid_string?(Map.get(attrs, "html")) do
          :ok
        else
          Errors.error(
            :content_item,
            :invalid_content_item,
            "Content item type #{type} requires html",
            %{type: type}
          )
        end
    end
  end

  defp fetch_string(attrs, key) do
    case Map.get(attrs, key) do
      value when is_binary(value) and value != "" -> value
      _ -> nil
    end
  end

  defp fetch_map(attrs, key) do
    case Map.get(attrs, key) do
      value when is_map(value) -> value
      _ -> nil
    end
  end

  defp valid_string?(value), do: is_binary(value) and value != ""
end
