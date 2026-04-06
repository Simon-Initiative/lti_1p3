# AGENTS

This repository packages an Elixir library for building LTI 1.3 Tool and Platform integrations.

## Table Of Contents

- `README.md`: public usage guide, installation, and end-to-end examples for tool and platform flows.
- `ARCHITECTURE.md`: system map for the library modules, pluggable providers, and key management flow.
- `docs/STACK.md`: language, runtime, and dependency baseline for the library.
- `docs/TOOLING.md`: day-to-day commands, formatting, compile, and publish workflow.
- `docs/TESTING.md`: ExUnit test layout, mocks, and required verification gates.
- `docs/OPERATIONS.md`: operational expectations for a library release, observability limits, and performance notes.
- `docs/FRONTEND.md`: guidance for example consumer UIs; the library itself does not ship a frontend.
- `docs/PRODUCT_SENSE.md`: product intent and repository-level assumptions.
- `docs/BACKEND.md`: backend boundaries for library consumers and core modules.
- `docs/SECURITY.md`: security-sensitive areas around keys, JWT validation, nonce handling, and LTI handshake data.

## Working Notes

- Treat this repository as a reusable package, not a deployable service.
- Prefer facts grounded in `README.md`, `mix.exs`, `config/*.exs`, `docs/*.md`, and GitHub workflows over assumptions.
- There is already a user change in `mix.exs`; do not overwrite it unless explicitly asked.
