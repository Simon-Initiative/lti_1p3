defmodule Lti_1p3.NoncesTest do
  use Lti_1p3.Test.TestCase

  import Lti_1p3.DataProviders.EctoProvider.Config

  alias Lti_1p3.DataProviders.EctoProvider
  alias Lti_1p3.Nonces

  describe "lti 1.3 nonces" do
    test "should create new nonce with default domain nil" do
      {:ok, nonce} = Nonces.create_nonce("some-value")

      assert nonce.value == "some-value"
      assert nonce.domain == nil
    end

    test "should create new nonce with specified domain" do
      {:ok, nonce} = Nonces.create_nonce("some-value", "some-domain")

      assert nonce.value == "some-value"
      assert nonce.domain == "some-domain"
    end

    test "should create new nonce with specified domain if one already exists with different domain" do
      {:ok, _nonce1} = Nonces.create_nonce("some-value")
      {:ok, _nonce2} = Nonces.create_nonce("some-value", "some-domain")
      {:ok, nonce3} = Nonces.create_nonce("some-value", "different-domain")

      assert nonce3.value == "some-value"
      assert nonce3.domain == "different-domain"
    end

    test "should fail to create new nonce if one already exists with specified domain" do
      {:ok, _nonce} = Nonces.create_nonce("some-value", "some-domain")

      assert {:error, %Lti_1p3.DataProviderError{msg: "value: has already been taken"}} = Nonces.create_nonce("some-value", "some-domain")
    end

    test "should cleanup expired nonces" do
      {:ok, nonce} = Nonces.create_nonce("some-value")

      # verify the nonce exists before cleanup
      assert Nonces.get_nonce(nonce.id) == nonce

      # fake the nonce was created a day + 1 hour ago
      a_day_before = Timex.now |> Timex.subtract(Timex.Duration.from_hours(25))
      repo!().get(EctoProvider.Nonce, nonce.id)
      |> Ecto.Changeset.cast(%{inserted_at: a_day_before}, [:inserted_at])
      |> repo!().update!

      # cleanup
      Nonces.cleanup_nonce_store()

      # no more nonce
      assert Nonces.get_nonce(nonce.id) == nil
    end
  end
end
