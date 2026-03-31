# Security

## Requirements

- Never expose private keys in docs, examples, or code paths meant for consumers
- Preserve nonce, state, issuer, audience, and deployment validation behavior
- Treat remote JWK fetching and cache invalidation as security-sensitive code
- Maintain clear separation between public JWK exposure and private key storage
- Review any claim parsing change for spoofing, replay, or authorization implications
