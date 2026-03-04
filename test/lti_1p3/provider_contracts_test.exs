defmodule Lti_1p3.ProviderContractsTest do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.DataProviderError

  test "tool provider get_jwk_by_registration returns tuple contract" do
    jwk = jwk_fixture()
    registration = registration_fixture(%{tool_jwk_id: jwk.id})

    assert {:ok, returned_jwk} = Lti_1p3.Config.provider!().get_jwk_by_registration(registration)
    assert returned_jwk.id == jwk.id
  end

  test "tool provider get_jwk_by_registration returns not_found error when missing" do
    registration = registration_fixture(%{tool_jwk_id: -1})

    assert {:error, %DataProviderError{reason: :not_found}} =
             Lti_1p3.Config.provider!().get_jwk_by_registration(registration)
  end

  test "tool provider get_registration_deployment returns tuple with nils when absent" do
    assert {nil, nil} =
             Lti_1p3.Config.provider!().get_registration_deployment(
               "missing",
               "missing",
               "missing"
             )
  end
end
