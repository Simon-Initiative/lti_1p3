# Tool AGS Guide

Use `Lti_1p3.Tool.Services.AGS` to parse AGS launch claims, enforce operation scope preflight, and run line item/score/result operations.

## Parse Endpoint From Launch Claim

```elixir
with {:ok, endpoint} <- Lti_1p3.Tool.Services.AGS.from_launch_claim(launch.claims) do
  endpoint.line_items_url
end
```

## Line Item Operations

```elixir
with {:ok, endpoint} <- Lti_1p3.Tool.Services.AGS.from_launch_claim(launch.claims),
     {:ok, access_token} <-
       Lti_1p3.Tool.Services.AccessToken.fetch_access_token(
         registration,
         Lti_1p3.Tool.Services.AGS.required_scopes(:create_line_item),
         host
       ),
     {:ok, line_item} <-
       Lti_1p3.Tool.Services.AGS.create_line_item(endpoint, access_token, %{
         scoreMaximum: 100,
         label: "Homework 1",
         resourceId: "resource-1"
       }) do
  {:ok, line_item}
end
```

List and page through line items:

```elixir
Lti_1p3.Tool.Services.AGS.list_line_items(endpoint, access_token,
  limit: 100,
  resource_id: "resource-1",
  compatibility: %{default_line_items_limit: 1000}
)
```

## Score Posting

```elixir
score = %Lti_1p3.Tool.Services.AGS.Score{
  timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
  scoreGiven: 95,
  scoreMaximum: 100,
  comment: "Great job",
  activityProgress: "Completed",
  gradingProgress: "FullyGraded",
  userId: "student-123"
}

:ok =
  Lti_1p3.Tool.Services.AGS.post_score(
    line_item_url,
    endpoint,
    access_token,
    score
  )
```

## Result Retrieval

```elixir
with {:ok, page} <-
       Lti_1p3.Tool.Services.AGS.list_results(line_item_url, endpoint, access_token, limit: 50),
     {:ok, all_results} <-
       Lti_1p3.Tool.Services.AGS.fetch_all_results(line_item_url, endpoint, access_token,
         max_pages: 20,
         retry_count: 1
       ) do
  {:ok, page.items, all_results}
end
```

## Error Shape

AGS APIs return structured errors:

```elixir
{:error,
 %{
   reason: :insufficient_scope,
   operation: :post_score,
   http_status: nil,
   retryable: false,
   msg: "Missing required AGS scope",
   details: %{required_scope: required_scope, source: :token}
 }}
```

## Telemetry Events

Tool AGS emits telemetry per request/operation outcome:

- `[:lti_1p3, :tool, :ags, :request]`
- `[:lti_1p3, :tool, :ags, :line_item]`
- `[:lti_1p3, :tool, :ags, :result]`
- `[:lti_1p3, :tool, :ags, :error]`
- `[:lti_1p3, :tool, :ags, :scope_denied]`

## Legacy Compatibility

Legacy helpers are still available and keep historical return shapes:

- `post_score/3`
- `fetch_line_items/2`
- `create_line_item/5`
- `update_line_item/3`
- `fetch_or_create_line_item/5`
