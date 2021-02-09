defmodule Lti_1p3.Test.Ecto.Lti_1p3_User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lti_1p3_users" do
    # user fields are based on the openid connect core standard, most of which are provided via LTI 1.3
    # see https://openid.net/specs/openid-connect-core-1_0.html#StandardClaims for full descriptions
    field :sub, :string
    field :name, :string
    field :given_name, :string
    field :family_name, :string
    field :middle_name, :string
    field :nickname, :string
    field :preferred_username, :string
    field :profile, :string
    field :picture, :string
    field :website, :string
    field :email, :string
    field :email_verified, :boolean
    field :gender, :string
    field :birthdate, :string
    field :zoneinfo, :string
    field :locale, :string
    field :phone_number, :string
    field :phone_number_verified, :boolean
    field :address, :string

    field :platform_roles, :string
    field :context_roles, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [
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
    ])
    |> validate_required([:sub])
  end
end

# define implementations required for LTI 1.3 library integration
defimpl Lti_1p3.Tool.Lti_1p3_User, for: Lti_1p3.Test.Ecto.Lti_1p3_User do
  import Ecto.Query, warn: false

  def get_platform_roles(user) do
    user.platform_roles
    |> String.split(",")
    |> Lti_1p3.Tool.PlatformRoles.get_roles_by_uris()
  end

  def get_context_roles(user, _context_id) do
    user.platform_roles
    |> String.split(",")
    |> Lti_1p3.Tool.ContextRoles.get_roles_by_uris()
  end
end
