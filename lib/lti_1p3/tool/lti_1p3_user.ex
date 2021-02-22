# Protocol a user struct must implement in order to utilize certain lti 1.3 functionality
defprotocol Lti_1p3.Tool.Lti_1p3_User do
  def get_platform_roles(user, registration)
  def get_context_roles(user, registration, context_id)
end

defimpl Lti_1p3.Tool.Lti_1p3_User, for: Any do
  def get_platform_roles(_user, _registration), do: []
  def get_context_roles(_user, _registration, _context_id), do: []
end
