# Protocol a user struct must implement in order to utilize certain lti 1.3 functionality
defprotocol Lti_1p3.Tool.Lti_1p3_User do
  @doc """
  Returns all platform roles for a given user

  ## Examples
      iex> get_platform_roles(%Lti_1p3.Tool.Lti_1p3_User{})
      [%PlatformRole{}]
  """
  def get_platform_roles(user)

  @doc """
  Returns all context roles for a given user and context.

  The context here is determined by the actual implementation needs and is intended to
  give the implementation a unique context for which a user has roles, such as a course section identifier.
  If your tool supports more than one LMS platform, this context data must uniquely identify the specific
  context across all platforms, for example, using a combination of the issuer, client_id and and context_id

  ## Examples
      iex> get_platform_roles(%Lti_1p3.Tool.Lti_1p3_User{}, "issuer-client_id-context_id")
      [%ContextRole{}]
  """
  def get_context_roles(user, context)
end

defimpl Lti_1p3.Tool.Lti_1p3_User, for: Any do
  def get_platform_roles(_user), do: []
  def get_context_roles(_user, _context), do: []
end
