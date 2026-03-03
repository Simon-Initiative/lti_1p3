---
name: feature-architect
description: "Produce complete feature architecture deliverables from informal requests. Use when Codex must convert a rough feature idea into implementation-ready planning documents: product requirements (`prd.md`), functional design (`fdd.md`), and a phased execution plan (`plan.md`) with checkbox task tracking. Prioritize Elixir, Erlang, OTP/BEAM, and web architecture best practices."
---

# Feature Architect

Create a cohesive architecture package that an engineer can implement without re-interpreting intent.

## Workflow

1. Capture feature intent
- Parse the informal request into: problem, users, desired outcomes, constraints, and unknowns.
- State assumptions explicitly when inputs are missing.
- Ask concise follow-up questions only when unknowns materially change design or scope.

2. Define scope and boundaries
- Separate in-scope work from out-of-scope work.
- Define release slices (MVP vs later phases).
- Identify dependencies, risks, migration needs, and rollout constraints.

3. Design for Elixir/OTP web systems
- Use [references/elixir-architecture.md](references/elixir-architecture.md) to choose runtime structure, process boundaries, supervision strategy, persistence model, and observability.
- Prefer fault-tolerant process design, clear module boundaries, and explicit contracts between contexts.

4. Produce required outputs
- Generate exactly three files: `prd.md`, `fdd.md`, and `plan.md`.
- Use [references/document-templates.md](references/document-templates.md) as the default structure.
- Keep all three documents internally consistent for naming, scope, and acceptance criteria.

5. Validate package quality
- Verify every functional requirement maps to design elements and implementation tasks.
- Ensure non-functional requirements (performance, reliability, security, operability) have concrete implementation considerations.
- Ensure plan tasks are actionable, testable, and sequenced.

## Output Requirements

Always produce:

1. `prd.md`
- Define user problem, business goals, target users, use cases, functional requirements, non-functional requirements, success metrics, and acceptance criteria.

2. `fdd.md`
- Define architecture, component/module responsibilities, data model changes, interfaces/contracts, runtime/process behavior, error handling, observability, security posture, and test strategy.

3. `plan.md`
- Define phased implementation with checkbox tasks.
- Use unchecked markdown checkboxes for pending work: `- [ ] Task`.
- Group tasks by phase and include explicit deliverables and verification steps.
- Keep tasks granular enough that progress can be tracked during implementation.

## Standards

- Design for maintainability, fault tolerance, and operational clarity.
- Prefer explicit tradeoff notes when multiple approaches are viable.
- Avoid vague tasks such as "implement feature"; break into concrete outcomes.
- Tie each phase to measurable completion criteria.
- Keep the architecture realistic for the current codebase and team maturity.
