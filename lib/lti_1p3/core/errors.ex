defmodule Lti_1p3.Core.Errors do
  @moduledoc """
  Canonical error helpers for core tool/platform flows.
  """

  @type t() :: %{
          reason: atom(),
          stage: atom(),
          msg: String.t(),
          details: map()
        }

  @spec error(atom(), atom(), String.t(), map()) :: {:error, t()}
  def error(stage, reason, msg, details \\ %{}) when is_atom(stage) and is_atom(reason) do
    {:error, %{reason: reason, stage: stage, msg: msg, details: details}}
  end

  @spec put_details(t(), map()) :: t()
  def put_details(%{details: details} = error, extra_details) when is_map(extra_details) do
    %{error | details: Map.merge(details, extra_details)}
  end
end
