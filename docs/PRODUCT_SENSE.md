# Product Sense

## Product Goals

- Provide a reusable Elixir implementation of the LTI 1.3 specification for both Tool and Platform integrations
- Keep the library flexible enough for different host applications by making persistence pluggable
- Reduce integration complexity by supplying clear examples, claim parsing helpers, and service abstractions
- Preserve interoperability and security expectations around OIDC login, JWT validation, keys, deployments, and nonces

## Assumptions

- Most users integrate this package into a Phoenix or Elixir web application rather than use it standalone
- Good package documentation is part of the product surface, not a secondary concern
- Backward-compatible API changes and secure defaults matter more than adding framework-specific convenience layers
