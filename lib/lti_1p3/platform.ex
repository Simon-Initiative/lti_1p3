defmodule Lti_1p3.Platform do
  import Lti_1p3.Config

  @doc """
  Creates a new platform instance.
  ## Examples
      iex> create_platform_instance(platform_instance)
      {:ok, %Lti_1p3.Platform.PlatformInstance{}}
      iex> create_platform_instance(platform_instance)
      {:error, %Lti_1p3.DataProviderError{}}
  """
  def create_platform_instance(%Lti_1p3.Platform.PlatformInstance{} = platform_instance), do:
    provider!().create_platform_instance(platform_instance)
end
