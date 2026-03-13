# Stack

## Languages

- Elixir `~> 1.17` is the implementation language for the library and test suite.
- Erlang/OTP underpins supervision, process-based key providers, and runtime services.
- YAML appears only in harness metadata such as [`harness.yml`](/Users/eliknebel/Developer/lti_1p3/harness.yml).

## Frameworks

- Mix drives compilation, formatting, docs, and test execution.
- `Joken` provides JWT signing and validation primitives.
- `HTTPoison` is used for outbound HTTP calls such as key retrieval and service requests.
- `Jason` handles JSON serialization.
- `Timex` and `UUID` support timestamp handling and correlation identifiers.
- `:telemetry` is the observability surface emitted by the library.
- The project intentionally stays framework-agnostic, with Phoenix/Plug integration shown only through examples and guides.

## Storage

- The default persistence adapter is `Lti_1p3.DataProviders.MemoryProvider`, which is volatile and best suited for tests or examples.
- Production storage is delegated to pluggable provider implementations supplied by consuming applications.
- The library itself does not ship an Ecto repo, SQL schema, or migration set.
