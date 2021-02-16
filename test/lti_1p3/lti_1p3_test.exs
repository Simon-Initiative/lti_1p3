defmodule Lti_1p3Test do
  use Lti_1p3.Test.TestCase

  alias Lti_1p3.Jwk

  describe "Lti_1p3" do
    test "should create and get the active jwk" do
      %{private_key: private_key} = Lti_1p3.KeyGenerator.generate_key_pair()

      {:ok, jwk} = Lti_1p3.create_jwk(%Jwk{
        pem: private_key,
        typ: "JWT",
        alg: "RS256",
        kid: UUID.uuid4(),
        active: true,
      })

      assert Lti_1p3.get_active_jwk() == {:ok, jwk}
    end

    test "should get all public keys" do
      %{private_key: private_key} = Lti_1p3.KeyGenerator.generate_key_pair()

      {:ok, jwk1} = Lti_1p3.create_jwk(%Jwk{
        pem: private_key,
        typ: "JWT",
        alg: "RS256",
        kid: UUID.uuid4(),
        active: false,
      })

      {:ok, jwk2} = Lti_1p3.create_jwk(%Jwk{
        pem: private_key,
        typ: "JWT",
        alg: "RS256",
        kid: UUID.uuid4(),
        active: true,
      })

      {:ok, jwk3} = Lti_1p3.create_jwk(%Jwk{
        pem: private_key,
        typ: "JWT",
        alg: "RS256",
        kid: UUID.uuid4(),
        active: true,
      })

      assert Lti_1p3.get_all_public_keys() == %{
        keys: [
          to_public_key(jwk1),
          to_public_key(jwk2),
          to_public_key(jwk3),
        ]
      }
    end
  end

  defp to_public_key(%Jwk{pem: pem, typ: typ, alg: alg, kid: kid}) do
    pem
    |> JOSE.JWK.from_pem
    |> JOSE.JWK.to_public
    |> JOSE.JWK.to_map()
    |> (fn {_kty, public_jwk} -> public_jwk end).()
    |> Map.put("typ", typ)
    |> Map.put("alg", alg)
    |> Map.put("kid", kid)
    |> Map.put("use", "sig")
  end
end
