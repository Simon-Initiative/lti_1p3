# Stack

## Languages

- Elixir `~> 1.17` in `mix.exs`
- Erlang/OTP `27.0.1` and Elixir `1.17.2-otp-27` in `.tool-versions`
- Markdown for user and maintainer documentation
- YAML for harness metadata

## Frameworks

- Mix for build, test, docs, and packaging workflows
- ExUnit for tests
- ExCoveralls for coverage reporting
- ExDoc for package documentation
- Joken for JWT handling
- HTTPoison for HTTP interactions with remote services and JWK endpoints
- Jason for JSON encoding/decoding
- Timex and UUID as supporting libraries

## Storage

- Library core is storage-agnostic through the `Lti_1p3.DataProvider` behavior
- Default examples and tests use `Lti_1p3.DataProviders.MemoryProvider`
- `docker-compose.yml` provides PostgreSQL for local work that needs a durable provider or integration experimentation, but no database-backed provider lives in this repository
