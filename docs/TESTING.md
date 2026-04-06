# Testing

## Test Types

- Unit tests for core library modules under `test/lti_1p3/**`
- Behavior and integration-style tests for launch validation, key provider supervision, AGS, NRPS, and platform flows
- Support helpers under `test/support/**`
- HTTP interactions are mocked in test via `Lti_1p3.Test.MockHTTPoison` configured in `config/test.exs`
- Tests run with `ExUnit.start(exclude: [:skip])` and logger backends disabled to keep output focused

## Required Gates

- `mix test`
- `mix compile --warnings-as-errors` for code paths touched by the change
- `mix test.coverage` when a change materially affects public flows or security-sensitive behavior
- Add or update tests when changing launch validation, claim parsing, key caching, or service integrations
