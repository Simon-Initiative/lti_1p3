# Backend

## Service Architecture

- This project is a reusable backend library rather than a running backend service.
- Business logic is organized by domain modules under `lib/lti_1p3/`, with clear separation between tool flows, platform flows, shared validation, claims, roles, and provider infrastructure.
- OTP supervision is used for key-provider lifecycle management and cache refresh behavior.

## Backend Boundaries

- The library owns protocol logic, validation pipelines, typed structs, and behavior contracts.
- Consuming applications own HTTP routing, session storage, durable persistence, deployment topology, and external credential management.
- The library should not grow app-specific controllers, schemas, or product-domain workflows that are unrelated to LTI interoperability.
