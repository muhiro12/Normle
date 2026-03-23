# ADR 0002: Platform Adapters Stay in App Target

- Date: 2026-03-23
- Status: Accepted

## Context

Some Normle capabilities depend directly on Apple frameworks and app runtime
assembly, such as `ModelContainer` creation, CloudKit fallback, TipKit, route
intake, clipboard access, and file importer/exporter integration. Those
dependencies do not belong in the shared business layer.

## Decision

Keep platform-specific integrations in the `Normle` target. Do not add app
runtime or persistence-bootstrap behavior to `NormleLibrary`.

## Consequences

- `NormleAppModelContainerFactory` is app-owned.
- `NormlePlatformEnvironmentFactory` remains app-owned.
- TipKit, route handling, and destructive reset orchestration stay in the app
  target.
- `NormleLibrary` stays focused on platform-neutral business logic plus schema
  contracts.
