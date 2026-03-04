# Provider Adapter Migration Checklist

Use this checklist when updating custom providers to match core contract changes.

## ToolDataProvider contract checks

- `get_registration_deployment/3` returns `{registration_or_nil, deployment_or_nil}`.
- `get_jwk_by_registration/1` returns:
  - `{:ok, %Lti_1p3.Jwk{}}`
  - `{:error, %Lti_1p3.DataProviderError{reason: :not_found | ...}}`

## Error hygiene

- Use stable `DataProviderError.reason` atoms.
- Keep error tuples and struct shapes deterministic.

## Conformance tests

Run provider contract tests after adapter updates:

```bash
mix test test/lti_1p3/provider_contracts_test.exs
```

## Optional adapter regression checks

- Tool launch validation with valid registration + deployment.
- Duplicate nonce rejection path.
- Platform authorization nonce reuse rejection path.
