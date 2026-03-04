# Core Troubleshooting

## `invalid_oidc_state`

- Ensure session state is persisted between login and launch.
- Verify cookie behavior in iframe contexts.

## `invalid_registration`

- Confirm `iss` and `aud` resolve to an existing tool registration.
- Verify client ID and issuer values exactly match stored registration values.

## `invalid_audience`

- `aud` must contain expected client ID.
- For multi-audience tokens, `azp` must equal expected client ID.

## `signature_error` / key resolution errors

- Validate `kid` is present in JWT header.
- Confirm key set URL is reachable and includes matching `kid`.

## `invalid_nonce`

- Nonce reuse is rejected by design.
- Check retry/replay behavior in caller code.
