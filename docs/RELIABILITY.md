# Reliability

## Expectations

- Launch validation should fail deterministically with structured errors
- Key retrieval should prefer cached data and degrade gracefully when refresh fails
- In-memory defaults are suitable for examples and tests, not for durable production storage
- Changes that affect registration, deployment, or nonce behavior need regression coverage
