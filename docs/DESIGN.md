# Design

## Principles

- Prefer small, focused modules grouped by LTI domain.
- Use pure functions, pattern matching, and tagged tuples for recoverable errors.
- Centralize security validation so protocol invariants are enforced consistently.
- Keep extension points behind behaviors rather than embedding application-specific persistence or networking assumptions.
- Favor documentation and tests that make the public integration contract explicit.
