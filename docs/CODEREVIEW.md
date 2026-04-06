# Code Review

## Policy

Review changes as library changes first, application changes second. Prioritize:

- API compatibility for public modules and structs
- Security regressions in login, launch validation, nonce handling, and key retrieval
- Incorrect assumptions about provider behavior or storage semantics
- Documentation drift in `README.md` and `docs/*.md` when setup or flows change

## Review Guides

- Check whether tests cover changed public behavior
- Check whether `mix compile --warnings-as-errors` and `mix test` still pass
- Check whether example snippets remain aligned with the actual API
- Check whether network, cache, or cryptographic behavior changed without explicit rationale
