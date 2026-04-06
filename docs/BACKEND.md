# Backend

## Service Architecture

This repository is a backend library. Core responsibilities are:

- construct and validate LTI 1.3 requests and responses
- manage platform and tool metadata structures
- parse claims and roles
- integrate with pluggable persistence and key providers
- call AGS and NRPS service endpoints

## Backend Boundaries

- No owned web server, router, controller, or HTML rendering layer
- No first-party durable database implementation in this repository
- No background job system beyond what consumers wire into their supervision tree
