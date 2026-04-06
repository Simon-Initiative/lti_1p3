# Design

## Principles

- Favor explicit module boundaries that map to LTI concepts such as tool, platform, claims, roles, and services
- Keep host-application concerns pluggable instead of baking in Phoenix or Ecto dependencies
- Document integration flows with executable-looking examples so consumers can wire the library correctly
- Protect correctness and security in handshake code before optimizing ergonomics
