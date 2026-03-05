# Tool NRPS Guide

Use `Lti_1p3.Tool.Services.NRPS` to parse NRPS launch claims, enforce scope preflight, and retrieve memberships with paging.

## Parse Endpoint From Launch Claim

```elixir
with {:ok, endpoint} <- Lti_1p3.Tool.Services.NRPS.from_launch_claim(launch.claims) do
  endpoint.context_memberships_url
end
```

## List a Single Membership Page

```elixir
with {:ok, endpoint} <- Lti_1p3.Tool.Services.NRPS.from_launch_claim(launch.claims),
     {:ok, access_token} <-
       Lti_1p3.Tool.Services.AccessToken.fetch_access_token(
         registration,
         Lti_1p3.Tool.Services.NRPS.required_scopes(),
         host
       ),
     {:ok, page} <-
       Lti_1p3.Tool.Services.NRPS.list_memberships(endpoint, access_token,
         limit: 100,
         role: "Instructor",
         status: "Active"
       ) do
  {:ok, page.memberships, page.next_url}
end
```

## Stream Across Pages

```elixir
stream = Lti_1p3.Tool.Services.NRPS.stream_memberships(endpoint, access_token)

memberships =
  stream
  |> Enum.reduce_while([], fn
    {:error, error}, _acc -> {:halt, {:error, error}}
    membership, acc -> {:cont, [membership | acc]}
  end)
```

## Eager Fetch-All With Guardrails

```elixir
Lti_1p3.Tool.Services.NRPS.fetch_all_memberships(endpoint, access_token,
  max_pages: 20,
  retry_count: 1
)
```

## Error Shape

NRPS APIs return structured errors:

```elixir
{:error,
 %{
   reason: :insufficient_scope,
   msg: "Missing required NRPS scope",
   details: %{required_scope: required_scope, available_scopes: scopes},
   retryable: false
 }}
```

## Telemetry Events

Tool NRPS emits telemetry per request/page/error:

- `[:lti_1p3, :tool, :nrps, :request]`
- `[:lti_1p3, :tool, :nrps, :page]`
- `[:lti_1p3, :tool, :nrps, :membership]`
- `[:lti_1p3, :tool, :nrps, :error]`

These map to the NRPS metrics in `docs/features/tool-nrps/fdd.md`.

## Utility Reuse Notes

Shared helper modules extracted for future platform reuse:

- `Lti_1p3.Services.HTTP.LinkHeader`
- `Lti_1p3.Services.HTTP.QueryFilters`
