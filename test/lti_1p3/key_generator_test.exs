defmodule Lti_1p3.KeyGeneratorTest do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.KeyGenerator

  describe "key generator" do
    test "passphrase/0 generates a random passphrase of size 256" do
      assert String.length(KeyGenerator.passphrase) == 256
    end

    test "generate_key_pair/0 generates a public and private key pair" do
      keypair = KeyGenerator.generate_key_pair

      assert Map.has_key?(keypair, :public_key)
      assert Map.has_key?(keypair, :private_key)
      assert Map.has_key?(keypair, :key_id)
    end

  end
end
