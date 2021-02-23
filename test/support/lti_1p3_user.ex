defmodule Lti_1p3.Test.Lti_1p3_UserMock do
  @enforce_keys [:sub]
  defstruct [
    :id,
    :sub,
    :name,
    :given_name,
    :family_name,
    :middle_name,
    :nickname,
    :preferred_username,
    :profile,
    :picture,
    :website,
    :email,
    :email_verified,
    :gender,
    :birthdate,
    :zoneinfo,
    :locale,
    :phone_number,
    :phone_number_verified,
    :address,

    # comma seperated string representations of a user's roles
    :platform_roles,
    :context_roles
  ]

  @type t() :: %__MODULE__{
    id: integer(),
    sub: String.t(),
    name: String.t(),
    given_name: String.t(),
    family_name: String.t(),
    middle_name: String.t(),
    nickname: String.t(),
    preferred_username: String.t(),
    profile: String.t(),
    picture: String.t(),
    website: String.t(),
    email: String.t(),
    email_verified: boolean(),
    gender: String.t(),
    birthdate: String.t(),
    zoneinfo: String.t(),
    locale: String.t(),
    phone_number: String.t(),
    phone_number_verified: boolean(),
    address: String.t(),

    platform_roles: [String.t()],
    context_roles: [String.t()],
  }
end

# define implementations required for LTI 1.3 library integration
defimpl Lti_1p3.Tool.Lti_1p3_User, for: Lti_1p3.Test.Lti_1p3_UserMock do
  def get_platform_roles(user) do
    user.platform_roles
    |> Lti_1p3.Tool.PlatformRoles.get_roles_by_uris()
  end

  def get_context_roles(user, context) do
    if context == "some-test-context" do
      user.context_roles
      |> Lti_1p3.Tool.ContextRoles.get_roles_by_uris()
    else
      []
    end
  end
end
