# Tool Deep Linking Guide

This guide covers tool-side deep-linking request validation and response generation.

## Validate a Deep-Linking Request

Use the claims from a validated launch to build a typed request:

```elixir
{:ok, request} =
  Lti_1p3.Tool.validate_deep_linking_request(launch.claims)
```

The request includes typed deep-linking settings (`deep_link_return_url`, accepted content types, accepted presentation targets, and optional `data`).

## Build Content Items

Build supported content item types with deterministic validation errors:

```elixir
{:ok, item} =
  Lti_1p3.Tool.deep_linking_content_item(:lti_resource_link, %{
    "url" => "https://tool.example.com/resources/42",
    "title" => "Homework 1"
  })
```

Supported item types:

- `:lti_resource_link`
- `:link`
- `:file`
- `:image`
- `:html`

## Build and Sign a Response

Generate a signed `LtiDeepLinkingResponse` JWT payload for form-post to the return URL:

```elixir
{:ok, %{jwt: jwt, return_url: return_url}} =
  Lti_1p3.Tool.build_deep_linking_response(request, [item])
```

Compatibility behavior for LMS subtype variance can be controlled with options:

```elixir
{:ok, payload} =
  Lti_1p3.Tool.build_deep_linking_response(request, [item],
    unsupported_type_strategy: :filter_unsupported
  )
```

## Error Shape

All tool deep-linking APIs return deterministic error maps:

```elixir
%{reason: atom(), stage: atom(), msg: String.t(), details: map()}
```

Common reasons include:

- `:invalid_deep_linking_request`
- `:invalid_deep_linking_settings`
- `:unsupported_content_item_type`
- `:invalid_content_item`
- `:no_supported_content_items`
- `:response_signing_failed`

## Telemetry

Tool deep-linking emits:

- `[:lti_1p3, :tool, :deep_linking, :request]`
- `[:lti_1p3, :tool, :deep_linking, :response]`

Metadata includes `:result`, and when available, `:issuer`, `:client_id`, `:item_count`, and `:reason`.

## Utility Reuse Notes

Shared deep-linking claim keys are centralized in:

- `Lti_1p3.DeepLinking.ClaimKeys`

Tool modules consume this helper to reduce hard-coded claim key drift before platform deep-linking implementation.
