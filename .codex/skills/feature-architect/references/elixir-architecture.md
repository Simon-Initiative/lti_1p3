# Elixir/OTP Architecture Guardrails

Use this reference to keep designs aligned with BEAM strengths.

## 1. System Decomposition

- Organize by domain context, not by transport or framework layer alone.
- Keep context APIs explicit and stable; avoid leaking persistence concerns.
- Model long-lived concerns as supervised processes when stateful behavior is required.

## 2. OTP Process Design

- Prefer supervised, isolated processes over shared mutable state.
- Define restart strategy intentionally (`:one_for_one`, `:rest_for_one`, etc.).
- Bound process responsibilities; avoid "god" GenServers.
- Prefer stateless functions unless process state provides clear value.

## 3. Concurrency and Reliability

- Design for message ordering realities and idempotency.
- Use backpressure-aware patterns for throughput control.
- Define timeout, retry, and dead-letter behavior explicitly.
- Prefer `Task.Supervisor` or job systems for controlled async work.

## 4. Persistence and Data Integrity

- Keep transactional boundaries explicit in Ecto contexts.
- Use database constraints as correctness guarantees, not only app checks.
- Plan zero-downtime migrations for production paths.
- Include backfill and rollback strategies for schema evolution.

## 5. Phoenix/Web Layer

- Keep controllers and live views thin; move domain logic into contexts.
- Validate and normalize inputs at boundaries.
- Design APIs with explicit contracts and versioning strategy when needed.
- Use caching and pagination intentionally for read-heavy paths.

## 6. Observability and Operability

- Add Telemetry events for key business and system flows.
- Define essential metrics: latency, throughput, error rate, saturation.
- Include structured logs with correlation IDs.
- Document operational runbooks for failure modes and recovery.

## 7. Security

- Apply least privilege across service and data boundaries.
- Protect sensitive fields at rest and in transit.
- Record auditable events for security-relevant actions.
- Validate authorization decisions in domain-level workflows, not only controllers.

## 8. Testing Expectations

- Unit-test domain rules and pure logic heavily.
- Integration-test boundary behavior (DB, queues, APIs).
- Include property tests where invariants matter.
- Test failure and recovery paths for OTP processes.

## 9. Architecture Decision Quality

For each major choice, document:
- Decision
- Alternatives considered
- Tradeoffs
- Operational impact
- Migration and rollback implications
