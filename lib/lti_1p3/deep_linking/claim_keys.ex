defmodule Lti_1p3.DeepLinking.ClaimKeys do
  @moduledoc """
  Shared deep-linking claim key helpers.
  """

  @message_type "https://purl.imsglobal.org/spec/lti/claim/message_type"
  @version "https://purl.imsglobal.org/spec/lti/claim/version"
  @roles "https://purl.imsglobal.org/spec/lti/claim/roles"
  @deep_linking_settings "https://purl.imsglobal.org/spec/lti-dl/claim/deep_linking_settings"
  @content_items "https://purl.imsglobal.org/spec/lti-dl/claim/content_items"
  @data "https://purl.imsglobal.org/spec/lti-dl/claim/data"

  @type key_name ::
          :message_type
          | :version
          | :roles
          | :deep_linking_settings
          | :content_items
          | :data

  @spec key(key_name()) :: String.t()
  def key(:message_type), do: @message_type
  def key(:version), do: @version
  def key(:roles), do: @roles
  def key(:deep_linking_settings), do: @deep_linking_settings
  def key(:content_items), do: @content_items
  def key(:data), do: @data
end
