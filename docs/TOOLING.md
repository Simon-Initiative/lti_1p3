# Tooling

## Commands

- `mix compile` compiles the library.
- `mix test` runs the full test suite.
- `mix test path/to/file_test.exs` and `mix test path/to/file_test.exs:LINE` are the primary focused-test workflows.
- `mix format` formats touched Elixir files.
- `mix docs` generates HexDocs output.
- `mix test.coverage` and `mix test.coverage.xml` generate coverage reports through ExCoveralls.

## Required Gates

- New work should pass `mix format` and `mix test` before review.
- Public API changes should update docs and changelog entries, and should preserve existing tuple/error contracts unless a deliberate breaking change is planned.
- Security-sensitive changes should be validated against the relevant LTI and IMS security flows already documented in the repository.
