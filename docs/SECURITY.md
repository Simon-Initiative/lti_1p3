# Security

## Requirements

- Never expose private JWK material; only publish public JWK sets.
- Preserve JWT signature validation, issuer/audience checks, `exp`/`iat` handling, nonce uniqueness, state validation, registration lookup, and deployment validation.
- Keep security-sensitive defaults explicit and documented, especially cache, nonce, and login-hint TTL behavior.
- Avoid weakening provider boundaries that allow host applications to supply secure persistence and key-management implementations.
- Security-related behavior changes require tests for both acceptance and rejection paths.
