# Testing

## Test Types

- Unit and integration-style tests live under `test/lti_1p3/**`.
- Provider contract coverage verifies behavior-driven persistence and key-provider boundaries.
- Flow tests cover tool launch validation, platform authorization redirects, service clients, roles, and helper modules.
- Failure-path assertions are important in this repository because callers pattern-match on specific reason atoms and tagged-tuple return shapes.

## Required Gates

- Run `mix test` for any non-trivial change.
- Run targeted tests first when iterating on a specific LTI surface area, then rerun the full suite before finalizing.
- Add or update tests for both success and failure paths whenever protocol validation, provider behavior, or security checks change.
