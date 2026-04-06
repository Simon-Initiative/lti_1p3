# LTI Advantage Complete Modernization Epic - Child Features

## Child Feature List
1. Core Tool API Modernization
2. Core Platform API Modernization
3. AGS Tool Support
4. AGS Platform Support
5. NRPS Tool Support
6. NRPS Platform Support
7. Deep Linking Tool Support
8. Deep Linking Platform Support
9. Certification Readiness, Coverage, and Release Evidence

## Recommended Dependency Order
1. Core Tool API Modernization
Reason: establishes the target top-level API patterns for registration, login, launch, errors, and shared data contracts used by service-specific tool features.

2. Core Platform API Modernization
Reason: establishes the target top-level API patterns for platform instance management, authorization redirect, launch construction, and shared data contracts used by service-specific platform features.

3. AGS Tool Support
Reason: depends on tool launch and access-token patterns but can proceed once core tool API direction is set.

4. NRPS Tool Support
Reason: shares tool-side token, service discovery, and claim handling patterns established by core tool work; can run in parallel with AGS Tool after the core tool feature stabilizes.

5. Deep Linking Tool Support
Reason: depends on tool-side launch validation and message handling conventions from core tool work; should be aligned before platform deep-linking request construction is finalized.

6. AGS Platform Support
Reason: depends on core platform API direction and should follow once platform-side integration patterns are stable.

7. NRPS Platform Support
Reason: depends on core platform API direction and can run in parallel with AGS Platform after shared platform patterns settle.

8. Deep Linking Platform Support
Reason: depends on core platform launch-building conventions and should align with the already-defined tool-side deep-linking response behavior.

9. Certification Readiness, Coverage, and Release Evidence
Reason: starts early as a cross-cutting concern but should complete after the service features are substantially implemented so the final evidence reflects actual shipped behavior.

## Parallelization Notes
- `AGS Tool`, `NRPS Tool`, and `Deep Linking Tool` can overlap after `Core Tool API Modernization` reaches a stable design boundary.
- `AGS Platform`, `NRPS Platform`, and `Deep Linking Platform` can overlap after `Core Platform API Modernization` reaches a stable design boundary.
- `Certification Readiness, Coverage, and Release Evidence` should accompany every feature, but its final consolidation belongs near the end of the epic.

## Suggested Next Work Items
- Create one child work item directory per feature under `docs/exec-plans/current/`.
- Keep child PRDs feature-specific and move detailed FRs and ACs from the epic into those child work items.
- Treat this epic as the parent artifact for scope, sequencing, and release-level success criteria.
