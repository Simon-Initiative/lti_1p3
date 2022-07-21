use Mix.Config

config :lti_1p3,
  http_client: Lti_1p3.Test.MockHTTPoison,
  provider: Lti_1p3.DataProviders.MemoryProvider

config :logger, backends: []
