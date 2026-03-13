# Frontend

## UI Rules

This repository does not contain a frontend application.

- Browser-facing login and launch endpoints are implemented by consuming applications, typically Phoenix or another Plug stack.
- Documentation and examples should remain UI-framework agnostic and focus on protocol boundaries, request handling, and session/state requirements.
- Frontend-specific behavior that matters here is limited to launch context concerns such as iframe cookie restrictions and redirect flows documented in `README.md`.
