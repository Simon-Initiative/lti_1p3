defmodule Lti_1p3.Tool.MessageValidator do
  @moduledoc false

  @callback can_validate?(map()) :: boolean()
  @callback validate(map()) :: :ok | {:error, map()}
end
