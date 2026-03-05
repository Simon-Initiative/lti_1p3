defmodule Lti_1p3.Tool.Services.NRPS.MembershipPage do
  @moduledoc """
  A single NRPS memberships page and traversal metadata.
  """

  alias Lti_1p3.Tool.Services.NRPS.Membership

  @enforce_keys [:memberships, :next_url, :page_index, :request_url]
  defstruct [:memberships, :next_url, :page_index, :request_url]

  @type t() :: %__MODULE__{
          memberships: [Membership.t()],
          next_url: String.t() | nil,
          page_index: pos_integer(),
          request_url: String.t()
        }
end
