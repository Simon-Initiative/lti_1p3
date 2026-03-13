# Product Sense

## Product Goals

The product is an Elixir library for teams building LTI 1.3 tools, platforms, or both.

- Make protocol-correct LTI 1.3 flows available through stable, composable APIs.
- Keep the library framework-agnostic so Phoenix and non-Phoenix applications can integrate it cleanly.
- Preserve strong security defaults around JWT validation, nonce protection, key management, and deployment validation.
- Allow production adopters to plug in durable persistence and key-management implementations without rewriting core flow logic.
- Keep documentation practical enough that host applications can wire login, launch, AGS, NRPS, and platform redirects with low ambiguity.
