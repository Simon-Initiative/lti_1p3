---
name: software-developer
description: "Execute senior-level software implementation and bug fixing. Use when Codex should either (1) take feature docs such as `prd.md`, `fdd.md`, and `plan.md` and implement end-to-end, or (2) take an informal bug/issue report, diagnose root cause, propose a targeted fix or fix plan, and proceed with implementation after user confirmation when required."
---

# Software Developer

Implement production-ready changes with senior engineering rigor, from requirements to verified code.

## Mode Selection

Choose one mode based on input:

1. Feature Implementation Mode
- Trigger when the user provides feature artifacts (`prd.md`, `fdd.md`, `plan.md`) or asks for end-to-end implementation.
- Prefer loading these from `docs/features/<feature-slug>/`.
- Read [references/feature-execution.md](references/feature-execution.md).

2. Bug Fix Mode
- Trigger when the user provides an issue report, failing behavior, error logs, or regression symptoms.
- Read [references/bug-fix-playbook.md](references/bug-fix-playbook.md).

## Feature Implementation Mode

1. Build context
- Parse scope, acceptance criteria, constraints, and phased tasks from provided docs.
- Trace each planned task to concrete code changes and tests.
- Surface contradictions or missing requirements early.

2. Execute end-to-end
- Implement phase-by-phase in the order defined by `plan.md`.
- Treat each phase as a cohesive set of functionality and complete it before moving to the next phase.
- If `plan.md` includes PR groups, deliver phases according to that grouping while preserving phase order.
- Keep changes minimal but complete for each phase.
- Maintain existing code style and architecture conventions.

3. Validate and close
- Run relevant tests and linters.
- Confirm acceptance criteria are met.
- Update progress tracking checkboxes in `plan.md` for completed tasks and phases.
- Ensure the final phase (manual QA acceptance testing) is executed and recorded.

## Bug Fix Mode

1. Diagnose first
- Reproduce the issue when possible.
- Identify probable root cause and blast radius.
- Determine whether the fix is low-risk targeted or requires a planned multi-step approach.

2. Choose fix path
- Targeted fix path: implement immediately when root cause is clear and blast radius is small.
- Planned fix path: present concise analysis, recommended fix, and risk/validation plan, then request confirmation before editing code.

3. Implement and verify
- Apply the fix with minimal side effects.
- Add or update tests that fail before and pass after.
- Validate affected behavior and adjacent risk areas.

## Delivery Standards

- Explain assumptions and decisions concretely.
- Prefer root-cause fixes over superficial patches.
- Keep commits and diffs understandable and scoped.
- Explicitly call out what was verified and what was not verified.
