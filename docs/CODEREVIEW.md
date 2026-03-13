# Code Review

## Policy

- Review changes with a protocol-correctness and regression mindset first.
- Prioritize bugs, security regressions, return-shape changes, missing tests, and undocumented behavior changes over stylistic preferences.
- Treat public API stability as a review gate because downstream integrations may pattern-match on exact tuples, reason atoms, and structs.

## Review Guides

- Check the affected LTI surface area: Tool, Platform, shared core validation, provider contracts, or key-provider infrastructure.
- Confirm that success and failure paths are both covered in tests when validation or persistence behavior changes.
- Verify docs, changelog, and migration notes when user-visible behavior or setup requirements change.
