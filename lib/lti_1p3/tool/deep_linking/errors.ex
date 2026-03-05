defmodule Lti_1p3.Tool.DeepLinking.Errors do
  @moduledoc """
  Error helpers for tool deep-linking request validation and response generation.
  """

  @type t() :: %{
          reason: atom(),
          stage: atom(),
          msg: String.t(),
          details: map()
        }

  @spec error(atom(), atom(), String.t(), map()) :: {:error, t()}
  def error(stage, reason, msg, details \\ %{})
      when is_atom(stage) and is_atom(reason) and is_binary(msg) and is_map(details) do
    {:error, %{reason: reason, stage: stage, msg: msg, details: details}}
  end

  @spec to_message_validator_error(t()) :: %{reason: atom(), msg: String.t(), details: map()}
  def to_message_validator_error(%{reason: reason, msg: msg, details: details}) do
    %{reason: reason, msg: msg, details: details}
  end
end
