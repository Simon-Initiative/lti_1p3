# Key Provider System

The LTI 1.3 library now includes a robust key provider system that manages public key fetching, caching, and refreshing. This system replaces direct HTTP calls to key set URLs with a configurable, cacheable, and production-ready solution.

## Overview

The key provider system consists of:

1. **KeyProvider Behavior** - Defines the interface for key providers
2. **MemoryKeyProvider** - Production-ready in-memory implementation
3. **KeyProviderSupervisor** - Manages the key provider lifecycle
4. **Automatic Refresh** - Scheduled background key refreshing
5. **Cache Management** - Intelligent caching based on HTTP headers

## Quick Start

### 1. Add to Your Supervision Tree

Add the key provider supervisor to your application's supervision tree:

```elixir
# In your application.ex file
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      # ... your other children
      Lti_1p3.Examples.KeyProviderConfig.child_spec()
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
end
```

### 2. Configure Your Application

```elixir
# config/config.exs
config :lti_1p3,
  key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
  key_provider_cache_ttl: 3600,      # 1 hour
  key_provider_refresh_interval: 1800 # 30 minutes
```

### 3. Use in Your Code

The key provider works transparently with existing LTI launch validation:

```elixir
# This automatically uses the key provider for JWT validation
case Lti_1p3.Tool.LaunchValidation.validate(params, session_state) do
  {:ok, claims} ->
    # Handle successful launch
  {:error, reason} ->
    # Handle validation error
end
```

## Advanced Usage

### Preloading Keys

Warm up the cache by preloading keys from known platforms:

```elixir
# Preload keys during application startup
Lti_1p3.preload_keys("https://platform.example.edu/.well-known/jwks.json")
```

### Cache Management

Monitor and manage the key cache:

```elixir
# Get cache statistics
info = Lti_1p3.key_cache_info()
IO.inspect(info)
# => %{
#   cached_urls: ["https://platform.example.edu/.well-known/jwks.json"],
#   cache_entries_count: 1,
#   total_cached_keys: 3,
#   cache_hits: 42,
#   cache_misses: 5,
#   refresh_errors: 0,
#   hit_rate: 89.36
# }

# Manually refresh all cached keys
results = Lti_1p3.refresh_all_keys()

# Clear the cache (useful for testing)
Lti_1p3.clear_key_cache()
```

### Custom Configuration

Create custom configurations for different environments:

```elixir
# Production configuration
production_config = [
  key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
  refresh_interval: 1800,  # 30 minutes
  cache_ttl: 3600         # 1 hour
]

# Development configuration with faster refresh
development_config = [
  key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
  refresh_interval: 300,   # 5 minutes
  cache_ttl: 600          # 10 minutes
]

# Add to supervision tree
{Lti_1p3.KeyProviderSupervisor, production_config}
```

## Key Provider Implementation

### MemoryKeyProvider Features

The included `MemoryKeyProvider` offers:

- **Intelligent Caching**: Respects HTTP cache headers (Cache-Control, Expires)
- **Background Refresh**: Automatically refreshes stale keys
- **Error Handling**: Graceful handling of network errors and invalid responses
- **Metrics**: Tracks cache hits, misses, and error rates
- **Thread Safety**: Concurrent access support

### Cache Behavior

1. **Initial Fetch**: Keys are fetched on first access
2. **Cache Hit**: Subsequent requests use cached keys if not expired
3. **Cache Miss**: Expired or missing keys trigger a fresh fetch
4. **Background Refresh**: Scheduled refresh of stale keys
5. **Error Resilience**: Failed refreshes don't invalidate existing cache

### HTTP Header Support

The provider respects standard HTTP caching headers:

- `Cache-Control: max-age=3600` - Sets cache TTL
- `Expires: ...` - Alternative expiration time
- `Last-Modified: ...` - Stored for future conditional requests
- `ETag: ...` - Stored for future conditional requests

## Testing

### Test Configuration

Use the test configuration for fast, predictable testing:

```elixir
# In test_helper.exs or test setup
{Lti_1p3.KeyProviderSupervisor, [
  key_provider: Lti_1p3.KeyProviders.MemoryKeyProvider,
  refresh_interval: 0,  # Disable automatic refresh
  cache_ttl: 60        # Short TTL for testing
]}
```

### Mocking HTTP Requests

The system works with existing HTTP mocks:

```elixir
test "validates JWT with mocked keys" do
  MockHTTPoison
  |> expect(:get, fn url ->
    # Mock the key set response
    mock_get_jwk_keys(jwk)
  end)

  # Test your LTI launch validation
  assert {:ok, claims} = LaunchValidation.validate(params, state)
end
```

### Cache Testing

Test cache behavior directly:

```elixir
test "caches keys properly" do
  # Clear cache
  Lti_1p3.clear_key_cache()

  # First call should fetch from HTTP
  {:ok, key1} = Lti_1p3.get_public_key(url, kid)

  # Second call should hit cache
  {:ok, key2} = Lti_1p3.get_public_key(url, kid)

  assert key1 == key2

  # Verify cache stats
  info = Lti_1p3.key_cache_info()
  assert info.cache_hits >= 1
end
```

## Migration Guide

### From Direct HTTP Fetching

If you were using the library before v1.0, no code changes are required. The key provider system works transparently with existing code.

### Custom Key Fetching

If you implemented custom key fetching, you can now replace it with:

```elixir
# Old approach
defp fetch_platform_key(key_set_url, kid) do
  # Custom HTTP fetching logic
end

# New approach
defp fetch_platform_key(key_set_url, kid) do
  Lti_1p3.get_public_key(key_set_url, kid)
end
```

## Creating Custom Key Providers

You can implement custom key providers by implementing the `Lti_1p3.KeyProvider` behavior:

```elixir
defmodule MyApp.DatabaseKeyProvider do
  @behaviour Lti_1p3.KeyProvider

  @impl true
  def get_public_key(key_set_url, kid) do
    # Custom implementation using database, Redis, etc.
  end

  @impl true
  def preload_keys(key_set_url) do
    # Custom preloading logic
  end

  @impl true
  def refresh_all_keys() do
    # Custom refresh logic
  end

  @impl true
  def clear_cache() do
    # Custom cache clearing logic
  end

  @impl true
  def cache_info() do
    # Return cache information
  end
end
```

Then configure it in your application:

```elixir
config :lti_1p3,
  key_provider: MyApp.DatabaseKeyProvider
```

## Performance Considerations

### Memory Usage

The `MemoryKeyProvider` stores keys in memory. For applications with many different platforms, monitor memory usage and consider implementing a size-limited LRU cache.

### Refresh Strategy

The default refresh strategy is conservative:

- 30-minute refresh interval
- 1-hour default cache TTL
- Respects platform-provided cache headers

Adjust based on your platform's key rotation frequency and traffic patterns.

### Network Resilience

The system handles network failures gracefully:

- Failed refreshes don't invalidate existing cache
- Retries happen on next scheduled refresh
- Manual refresh available for immediate updates

## Security Considerations

### Key Validation

All fetched keys are validated:

- JSON structure verification
- JWK format validation
- Required fields checking

### Error Information

Error messages are designed to be informative without leaking sensitive information about your infrastructure.

### Cache Isolation

Each key set URL is cached independently, preventing cross-contamination between different platforms.
