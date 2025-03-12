defmodule Lti_1p3.Claims.LearningInformationServices do
  @moduledoc """
  A struct representing the lis claim in an LTI 1.3 request.

  https://www.imsglobal.org/spec/lti/v1p3#learning-information-services-lis-claim
  """

  defstruct [
    :person_sourcedid,
    :course_offering_sourcedid,
    :course_section_sourcedid
  ]

  @type t() :: %__MODULE__{
          person_sourcedid: String.t(),
          course_offering_sourcedid: String.t(),
          course_section_sourcedid: String.t()
        }

  def key, do: "https://purl.imsglobal.org/spec/lti/claim/lis"

  @doc """
  Create a new lis claim.
  """
  def lis(opts \\ []) do
    %__MODULE__{
      person_sourcedid: Keyword.get(opts, :person_sourcedid),
      course_offering_sourcedid: Keyword.get(opts, :course_offering_sourcedid),
      course_section_sourcedid: Keyword.get(opts, :course_section_sourcedid)
    }
  end
end

defimpl Lti_1p3.Claims.Claim, for: Lti_1p3.Claims.LearningInformationServices do
  def get_key(_), do: Lti_1p3.Claims.LearningInformationServices.key()

  def get_value(%Lti_1p3.Claims.LearningInformationServices{
        person_sourcedid: person_sourcedid,
        course_offering_sourcedid: course_offering_sourcedid,
        course_section_sourcedid: course_section_sourcedid
      }) do
    %{
      "person_sourcedid" => person_sourcedid,
      "course_offering_sourcedid" => course_offering_sourcedid,
      "course_section_sourcedid" => course_section_sourcedid
    }
  end
end
