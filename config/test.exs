use Mix.Config

config :lti_1p3,
  http_client: Lti_1p3.Test.MockHTTPoison,
  provider: Lti_1p3.DataProviders.EctoProvider,
  ecto_provider: [
    repo: Lti_1p3.Test.Repo,
  ]

config :lti_1p3, Lti_1p3.Test.Repo,
  username: System.get_env("TEST_DB_USER", "postgres"),
  password: System.get_env("TEST_DB_PASSWORD", "postgres"),
  database: System.get_env("TEST_DB_NAME", "lti_1p3_test"),
  hostname: System.get_env("TEST_DB_HOST", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "priv"
