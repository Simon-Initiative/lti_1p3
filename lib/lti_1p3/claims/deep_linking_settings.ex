defmodule Lti_1p3.Claims.DeepLinkingSettings do
  @moduledoc """
  A struct representing the deep linking settings claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti-dl/v2p0/#deep-linking-request-message
  """
  @enforce_keys [
    :deep_link_return_url,
    :accept_types,
    :accept_presentation_document_targets
  ]

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

  def key, do: "https://purl.imsglobal.org/spec/lti-dl/claim/deep_linking_settings"

  @doc """
  Create a new version claim.
  """
  def deep_linking_settings(
        deep_link_return_url,
        accept_types,
        accept_presentation_document_targets,
        opts
      ),
      do: %__MODULE__{
        deep_link_return_url: deep_link_return_url,
        accept_types: accept_types,
        accept_presentation_document_targets: accept_presentation_document_targets,
        accept_media_types: Keyword.get(opts, :accept_media_types),
        accept_multiple: Keyword.get(opts, :accept_multiple),
        accept_lineitem: Keyword.get(opts, :accept_lineitem),
        auto_create: Keyword.get(opts, :auto_create),
        title: Keyword.get(opts, :title),
        text: Keyword.get(opts, :text),
        data: Keyword.get(opts, :data)
      }
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.DeepLinkingSettings do
  def get_key(_), do: Lti_1p3.Claims.DeepLinkingSettings.key()

  def get_value(%Lti_1p3.Claims.DeepLinkingSettings{
        deep_link_return_url: deep_link_return_url,
        accept_types: accept_types,
        accept_presentation_document_targets: accept_presentation_document_targets,
        accept_media_types: accept_media_types,
        accept_multiple: accept_multiple,
        accept_lineitem: accept_lineitem,
        auto_create: auto_create,
        title: title,
        text: text,
        data: data
      }) do
    %{
      "deep_link_return_url" => deep_link_return_url,
      "accept_types" => accept_types,
      "accept_presentation_document_targets" => accept_presentation_document_targets,
      "accept_media_types" => accept_media_types,
      "accept_multiple" => accept_multiple,
      "accept_lineitem" => accept_lineitem,
      "auto_create" => auto_create,
      "title" => title,
      "text" => text,
      "data" => data
    }
  end
end
