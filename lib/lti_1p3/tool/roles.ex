defmodule Lti_1p3.Tool.Roles do
  alias Lti_1p3.Tool.Role
  alias Lti_1p3.Tool.Lti_1p3_User

  # Core system roles
  @system_administrator %Role{
    id: 1,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/system/person#Administrator"
  }

  @system_none %Role{
    id: 2,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/system/person#None"
  }

  # Non‑core system roles
  @system_account_admin %Role{
    id: 3,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/system/person#AccountAdmin"
  }

  @system_creator %Role{
    id: 4,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/system/person#Creator"
  }

  @system_sys_admin %Role{
    id: 5,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/system/person#SysAdmin"
  }

  @system_sys_support %Role{
    id: 6,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/system/person#SysSupport"
  }

  @system_user %Role{
    id: 7,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/system/person#User"
  }

  # Core institution roles
  @institution_administrator %Role{
    id: 8,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Administrator"
  }

  @institution_faculty %Role{
    id: 9,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Faculty"
  }

  @institution_guest %Role{
    id: 10,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Guest"
  }

  @institution_none %Role{
    id: 11,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#None"
  }

  @institution_other %Role{
    id: 12,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Other"
  }

  @institution_staff %Role{
    id: 13,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Staff"
  }

  @institution_student %Role{
    id: 14,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student"
  }

  # Non‑core institution roles
  @institution_alumni %Role{
    id: 15,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Alumni"
  }

  @institution_instructor %Role{
    id: 16,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Instructor"
  }

  @institution_learner %Role{
    id: 17,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Learner"
  }

  @institution_member %Role{
    id: 18,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Member"
  }

  @institution_mentor %Role{
    id: 19,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Mentor"
  }

  @institution_observer %Role{
    id: 20,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Observer"
  }

  @institution_prospective_student %Role{
    id: 21,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/institution/person#ProspectiveStudent"
  }

  # Core context roles
  @context_administrator %Role{
    id: 22,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Administrator"
  }

  @context_content_developer %Role{
    id: 23,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#ContentDeveloper"
  }

  @context_instructor %Role{
    id: 24,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor"
  }

  @context_learner %Role{
    id: 25,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner"
  }

  @context_mentor %Role{
    id: 26,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Mentor"
  }

  # Non‑core context roles
  @context_manager %Role{
    id: 27,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Manager"
  }

  @context_member %Role{
    id: 28,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Member"
  }

  @context_officer %Role{
    id: 29,
    uri: "http://purl.imsglobal.org/vocab/lis/v2/membership#Officer"
  }

  # NOTE: This is a marker role to be used in conjunction with a "real" role.
  # It indicates this user is created by the platform for testing different
  # user scenarios. The most common use case is when an instructor wants to view
  # the course as a student would see it, student-preview mode.
  #
  # See https://www.imsglobal.org/spec/lti/v1p3/#lti-vocabulary-for-system-roles
  @system_test_user %Role{
    id: 30,
    uri: "http://purl.imsglobal.org/vocab/lti/system/person#TestUser"
  }

  def list_roles(), do: [
    @system_administrator,
    @system_none,
    @system_account_admin,
    @system_creator,
    @system_sys_admin,
    @system_sys_support,
    @system_user,
    @institution_administrator,
    @institution_faculty,
    @institution_guest,
    @institution_none,
    @institution_other,
    @institution_staff,
    @institution_student,
    @institution_alumni,
    @institution_instructor,
    @institution_learner,
    @institution_member,
    @institution_mentor,
    @institution_observer,
    @institution_prospective_student,
    @context_administrator,
    @context_content_developer,
    @context_instructor,
    @context_learner,
    @context_mentor,
    @context_manager,
    @context_member,
    @context_officer,
    @system_test_user,
  ]

  @doc """
  Returns a role from a given atom if it is valid, otherwise returns nil
  """
  def get_role(:system_administrator), do: @system_administrator
  def get_role(:system_none), do: @system_none
  def get_role(:system_account_admin), do: @system_account_admin
  def get_role(:system_creator), do: @system_creator
  def get_role(:system_sys_admin), do: @system_sys_admin
  def get_role(:system_sys_support), do: @system_sys_support
  def get_role(:system_user), do: @system_user
  def get_role(:institution_administrator), do: @institution_administrator
  def get_role(:institution_faculty), do: @institution_faculty
  def get_role(:institution_guest), do: @institution_guest
  def get_role(:institution_none), do: @institution_none
  def get_role(:institution_other), do: @institution_other
  def get_role(:institution_staff), do: @institution_staff
  def get_role(:institution_student), do: @institution_student
  def get_role(:institution_alumni), do: @institution_alumni
  def get_role(:institution_instructor), do: @institution_instructor
  def get_role(:institution_learner), do: @institution_learner
  def get_role(:institution_member), do: @institution_member
  def get_role(:institution_mentor), do: @institution_mentor
  def get_role(:institution_observer), do: @institution_observer
  def get_role(:institution_prospective_student), do: @institution_prospective_student
  def get_role(:context_administrator), do: @context_administrator
  def get_role(:context_content_developer), do: @context_content_developer
  def get_role(:context_instructor), do: @context_instructor
  def get_role(:context_learner), do: @context_learner
  def get_role(:context_mentor), do: @context_mentor
  def get_role(:context_manager), do: @context_manager
  def get_role(:context_member), do: @context_member
  def get_role(:context_officer), do: @context_officer
  def get_role(:system_test_user), do: @system_test_user
  def get_role(_invalid), do: nil

  @doc """
  Returns a role from a given uri if it is valid, otherwise returns nil
  """
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/system/person#Administrator"), do: @system_administrator
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/system/person#None"), do: @system_none
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/system/person#AccountAdmin"), do: @system_account_admin
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/system/person#Creator"), do: @system_creator
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/system/person#SysAdmin"), do: @system_sys_admin
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/system/person#SysSupport"), do: @system_sys_support
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/system/person#User"), do: @system_user
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Administrator"), do: @institution_administrator
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Faculty"), do: @institution_faculty
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Guest"), do: @institution_guest
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#None"), do: @institution_none
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Other"), do: @institution_other
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Staff"), do: @institution_staff
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student"), do: @institution_student
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Alumni"), do: @institution_alumni
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Instructor"), do: @institution_instructor
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Learner"), do: @institution_learner
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Member"), do: @institution_member
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Mentor"), do: @institution_mentor
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#Observer"), do: @institution_observer
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/institution/person#ProspectiveStudent"), do: @institution_prospective_student
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Administrator"), do: @context_administrator
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#ContentDeveloper"), do: @context_content_developer
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor"), do: @context_instructor
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Learner"), do: @context_learner
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Mentor"), do: @context_mentor
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Manager"), do: @context_manager
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Member"), do: @context_member
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Officer"), do: @context_officer
  def get_role_by_uri("http://purl.imsglobal.org/vocab/lti/system/person#TestUser"), do: @system_test_user
  def get_role_by_uri(_invalid), do: nil

  @doc """
  Returns all valid roles from a list of uris
  """
  @spec get_roles_by_uris([String.t()]) :: [%Role{}]
  def get_roles_by_uris(uris) do
    # create a list only containing valid roles
    uris
      |> Enum.map(&(get_role_by_uri(&1)))
      |> Enum.filter(&(&1 != nil))
  end

  @doc """
  Returns true if a list of roles contains a given role
  """
  @spec contains_role?([Role.t()], Role.t()) :: boolean()
  def contains_role?(roles, role) when is_list(roles) do
    Enum.any?(roles, fn r -> r.uri == role.uri end)
  end

  @doc """
  Returns true if a user has a given role
  """
  @spec has_role?(Lti_1p3_User.t(), Role.t()) :: boolean()
  def has_role?(user, role) do
    roles = Lti_1p3_User.get_platform_roles(user)
    Enum.any?(roles, fn r -> r.uri == role.uri end)
  end

  @doc """
  Returns true if a user has any of the given roles
  """
  @spec has_roles?(Lti_1p3_User.t(), [Role.t()], :any) :: boolean()
  def has_roles?(user, roles, :any) when is_list(roles) do
    user_roles = Lti_1p3_User.get_platform_roles(user)
    user_roles_map = roles_map(user_roles)
    Enum.any?(roles, fn r -> user_roles_map[r.uri] == true end)
  end

  # Returns true if a user has all of the given roles
  @spec has_roles?(Lti_1p3_User.t(), [Role.t()], :all) :: boolean()
  def has_roles?(user, roles, :all) when is_list(roles) do
    user_roles = Lti_1p3_User.get_platform_roles(user)
    user_roles_map = roles_map(user_roles)
    Enum.all?(roles, fn r -> user_roles_map[r.uri] == true end)
  end

  # Returns a map with keys of all role uris with value true if the user has the role, false otherwise
  defp roles_map(roles) do
    Enum.reduce(list_roles(), %{}, fn r, acc -> Map.put_new(acc, r.uri, Enum.any?(roles, &(&1.uri == r.uri))) end)
  end

end
