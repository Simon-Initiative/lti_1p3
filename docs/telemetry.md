# Telemetry

This library emits `:telemetry` events for core validation flows so client applications can collect metrics, traces, and structured logs.

## Event Names

- Stage event: `[:lti_1p3, :core, :validation, :stage]`
- Outcome event: `[:lti_1p3, :core, :validation, :outcome]`

## Measurements

Both events currently emit:

- `%{count: 1}`

## Metadata

Common metadata fields:

- `:flow` - `:tool_launch` or `:platform_authorize_redirect`
- `:result` - `:ok` or `:error`
- `:correlation_id` - request correlation ID

Additional fields when available:

- `:stage` - validation stage atom (always present for stage events)
- `:reason` - reason atom for failures

## Attaching a Client Handler

Attach handlers in your application startup (for example, in your supervision tree init path):

```elixir
:telemetry.attach_many(
  "myapp-lti-telemetry",
  [
    [:lti_1p3, :core, :validation, :stage],
    [:lti_1p3, :core, :validation, :outcome]
  ],
  fn event, measurements, metadata, _config ->
    # Forward to OpenTelemetry / PromEx / StatsD / Logger
    Logger.info("lti telemetry", event: event, measurements: measurements, metadata: metadata)
  end,
  nil
)
```

## Correlation IDs

You can pass a custom correlation ID through API opts:

- `Lti_1p3.Tool.validate_launch(params, expected_state, correlation_id: "...")`
- `Lti_1p3.Platform.authorize_redirect(params, current_user, issuer, claims, correlation_id: "...")`

If omitted, the library generates a UUID.

## Logging Behavior

The library also logs stage/outcome summaries via `Logger`. Client apps can control log verbosity with standard Logger config.

## Stability Notes

- Event names are considered part of the public observability contract.
- Measurements/metadata may gain additional fields in future minor releases.

## Tool Service Events

This library also emits tool-service telemetry for NRPS and AGS flows.

Tool AGS events:

- `[:lti_1p3, :tool, :ags, :request]`
- `[:lti_1p3, :tool, :ags, :line_item]`
- `[:lti_1p3, :tool, :ags, :result]`
- `[:lti_1p3, :tool, :ags, :error]`
- `[:lti_1p3, :tool, :ags, :scope_denied]`

Tool NRPS events:

- `[:lti_1p3, :tool, :nrps, :request]`
- `[:lti_1p3, :tool, :nrps, :page]`
- `[:lti_1p3, :tool, :nrps, :membership]`
- `[:lti_1p3, :tool, :nrps, :error]`
