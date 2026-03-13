# Platform AGS Guide

Use `Lti_1p3.Platform.Services.AGS` to authorize tool AGS tokens and execute line item, score, and result operations against your configured platform data provider.

## Build AGS Context

```elixir
context = %{
  deployment_id: "deployment-1",
  context_id: "course-42",
  scopes: String.split(access_token_scope, " ", trim: true),
  claims: token_claims
}
```

`claims` must include:

- `https://purl.imsglobal.org/spec/lti/claim/deployment_id`
- `https://purl.imsglobal.org/spec/lti/claim/context` with an `id`
- `scope` (space-delimited string or list)

## Authorize an Operation

```elixir
:ok =
  Lti_1p3.Platform.Services.AGS.authorize_operation(
    context.claims,
    :list_line_items,
    context
  )
```

## Line Item Operations

```elixir
with {:ok, created} <-
       Lti_1p3.Platform.Services.AGS.create_line_item(context, %{
         scoreMaximum: 100,
         label: "Homework 1",
         resourceId: "resource-1"
       }),
     {:ok, page} <- Lti_1p3.Platform.Services.AGS.list_line_items(context, limit: 25),
     {:ok, read} <- Lti_1p3.Platform.Services.AGS.read_line_item(context, created.id),
     {:ok, updated} <-
       Lti_1p3.Platform.Services.AGS.update_line_item(context, read.id, %{
         scoreMaximum: 100,
         label: "Homework 1 Updated",
         resourceId: "resource-1"
       }),
     :ok <- Lti_1p3.Platform.Services.AGS.delete_line_item(context, updated.id) do
  page.items
end
```

## Score and Results Operations

```elixir
score = %Lti_1p3.Platform.Services.AGS.Score{
  timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
  scoreGiven: 95,
  scoreMaximum: 100,
  comment: "Great work",
  activityProgress: "Completed",
  gradingProgress: "FullyGraded",
  userId: "student-123"
}

:ok = Lti_1p3.Platform.Services.AGS.post_score(context, line_item_id, score)

{:ok, results_page} =
  Lti_1p3.Platform.Services.AGS.list_results(context, line_item_id,
    limit: 50,
    user_id: "student-123"
  )
```

## Error Shape

Platform AGS APIs return structured errors:

```elixir
{:error,
 %{
   reason: :insufficient_scope,
   operation: :create_line_item,
   http_status: 403,
   retryable: false,
   msg: "Missing required AGS scope",
   details: %{required_scope: required_scope, available_scopes: scopes}
 }}
```

## Telemetry Events

Platform AGS emits:

- `[:lti_1p3, :platform, :ags, :request]`
- `[:lti_1p3, :platform, :ags, :denied]`
- `[:lti_1p3, :platform, :ags, :error]`
- `[:lti_1p3, :platform, :ags, :line_item]`
- `[:lti_1p3, :platform, :ags, :score]`
- `[:lti_1p3, :platform, :ags, :result]`
