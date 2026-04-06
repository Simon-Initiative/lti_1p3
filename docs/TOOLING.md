# Tooling

## Commands

- `mix deps.get`: install dependencies
- `mix compile`: compile the library
- `mix compile --warnings-as-errors`: strict compile gate used in CI
- `mix test`: run the ExUnit suite
- `mix test.coverage`: generate HTML coverage via ExCoveralls
- `mix format`: format Elixir sources using `.formatter.exs`
- `mix docs`: generate ExDoc output
- `mix hex.build`: build the Hex package
- `mix hex.publish --yes`: publish a tagged release from CI

## Required Gates

- Format cleanly with `mix format`
- Compile successfully, ideally with `mix compile --warnings-as-errors`
- Pass `mix test`
- Keep public docs coherent when APIs or setup guidance change
- For release work, ensure the tag-based publish workflow remains valid
