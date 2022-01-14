defmodule Lti_1p3.Tool.RolesTest do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.Tool.Roles
  alias Lti_1p3.Test.Lti_1p3_UserMock

  describe "platform roles" do
    test "list_roles returns an ordered list of all roles that match values returned by get_role with the corresponding atom" do
      assert Roles.list_roles() == [
               Roles.get_role(:system_administrator),
               Roles.get_role(:system_none),
               Roles.get_role(:system_account_admin),
               Roles.get_role(:system_creator),
               Roles.get_role(:system_sys_admin),
               Roles.get_role(:system_sys_support),
               Roles.get_role(:system_user),
               Roles.get_role(:institution_administrator),
               Roles.get_role(:institution_faculty),
               Roles.get_role(:institution_guest),
               Roles.get_role(:institution_none),
               Roles.get_role(:institution_other),
               Roles.get_role(:institution_staff),
               Roles.get_role(:institution_student),
               Roles.get_role(:institution_alumni),
               Roles.get_role(:institution_instructor),
               Roles.get_role(:institution_learner),
               Roles.get_role(:institution_member),
               Roles.get_role(:institution_mentor),
               Roles.get_role(:institution_observer),
               Roles.get_role(:institution_prospective_student),
               Roles.get_role(:context_administrator),
               Roles.get_role(:context_content_developer),
               Roles.get_role(:context_instructor),
               Roles.get_role(:context_learner),
               Roles.get_role(:context_mentor),
               Roles.get_role(:context_manager),
               Roles.get_role(:context_member),
               Roles.get_role(:context_officer),
               Roles.get_role(:system_test_user)
             ]
    end

    test "get_role_by_uri returns the correct role" do
      assert Roles.list_roles() == [
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/system/person#Administrator"
               ),
               Roles.get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/system/person#None"),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/system/person#AccountAdmin"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/system/person#Creator"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/system/person#SysAdmin"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/system/person#SysSupport"
               ),
               Roles.get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/system/person#User"),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Administrator"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Faculty"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Guest"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#None"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Other"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Staff"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Alumni"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Instructor"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Learner"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Member"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Mentor"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Observer"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/institution/person#ProspectiveStudent"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/membership#Administrator"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/membership#ContentDeveloper"
               ),
               Roles.get_role_by_uri(
                 "http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor"
               ),
               Roles.get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Learner"),
               Roles.get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Mentor"),
               Roles.get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Manager"),
               Roles.get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Member"),
               Roles.get_role_by_uri("http://purl.imsglobal.org/vocab/lis/v2/membership#Officer"),
               Roles.get_role_by_uri("http://purl.imsglobal.org/vocab/lti/system/person#TestUser")
             ]
    end

    test "get_role returns nil for invalid role atom" do
      role = Roles.get_role(:unknown)

      assert role == nil
    end

    test "get_role_by_uri returns nil for invalid role uri" do
      role =
        Roles.get_role_by_uri(
          "http://purl.imsglobal.org/vocab/lis/v2/institution/person#SomeUknownRole"
        )

      assert role == nil
    end

    test "get_roles_by_uris returns all valid roles from a list of uris" do
      roles =
        Roles.get_roles_by_uris([
          "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Instructor",
          "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Learner",
          "http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor",
          "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner"
        ])

      assert roles == [
               Roles.get_role(:institution_instructor),
               Roles.get_role(:institution_learner),
               Roles.get_role(:context_instructor),
               Roles.get_role(:context_learner)
             ]
    end

    test "contains_role? returns true if a list of roles contains a given role" do
      roles =
        Roles.get_roles_by_uris([
          "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Instructor",
          "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Learner",
          "http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor",
          "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner"
        ])

      assert Roles.contains_role?(roles, Roles.get_role(:institution_instructor)) == true
      assert Roles.contains_role?(roles, Roles.get_role(:institution_learner)) == true
      assert Roles.contains_role?(roles, Roles.get_role(:institution_mentor)) == false
      assert Roles.contains_role?(roles, Roles.get_role(:context_instructor)) == true
      assert Roles.contains_role?(roles, Roles.get_role(:context_learner)) == true
      assert Roles.contains_role?(roles, Roles.get_role(:context_mentor)) == false
    end

    test "has_role? returns true if a user has a given role" do
      user =
        struct(Lti_1p3_UserMock, %{
          sub: "some-user-sub",
          platform_roles: [
            "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Learner"
          ],
          context_roles: [
            "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner",
          ],
        })

      assert Roles.has_role?(user, Roles.get_role(:institution_instructor)) == false
      assert Roles.has_role?(user, Roles.get_role(:institution_learner)) == true
      assert Roles.has_role?(user, "some-test-context", Roles.get_role(:context_instructor)) == false
      assert Roles.has_role?(user, "some-test-context", Roles.get_role(:context_learner)) == true
    end

    test "has_roles? with :any returns true if a user has any of the given roles" do
      user =
        struct(Lti_1p3_UserMock, %{
          sub: "some-user-sub",
          platform_roles: [
            "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Learner"
          ],
          context_roles: []
        })

      assert Roles.has_roles?(user, [Roles.get_role(:institution_instructor)], :any) == false

      assert Roles.has_roles?(
               user,
               [Roles.get_role(:institution_instructor), Roles.get_role(:institution_learner)],
               :any
             ) == true

      assert Roles.has_roles?(user, [Roles.get_role(:institution_learner)], :any) == true
      assert Roles.has_roles?(user, [], :any) == false
    end

    test "has_roles? with :all returns true if a user has all of the given roles" do
      user =
        struct(Lti_1p3_UserMock, %{
          sub: "some-user-sub",
          platform_roles: [
            "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Instructor",
            "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Learner"
          ],
          context_roles: []
        })

      assert Roles.has_roles?(user, [Roles.get_role(:institution_instructor)], :all) == true

      assert Roles.has_roles?(
               user,
               [Roles.get_role(:institution_instructor), Roles.get_role(:institution_learner)],
               :all
             ) == true

      assert Roles.has_roles?(
               user,
               [Roles.get_role(:institution_learner), Roles.get_role(:institution_mentor)],
               :all
             ) == false

      assert Roles.has_roles?(user, [], :all) == true
    end
  end
end
