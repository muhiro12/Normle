# ADR 0001: Shared Library Source of Truth

- Date: 2026-03-23
- Status: Accepted

## Context

Normle exposes the same core behaviors through multiple app flows: transform
execution, mapping import/export, history maintenance, restore, preview data,
and smoke tests. When those flows each own their own rules, behavior drifts and
maintenance gets expensive.

## Decision

`NormleLibrary` is the single source of truth for reusable business logic.
Shared models, schema contracts, transfer formats, restore logic, and mutation
services belong there.

## Consequences

- New reusable operations should be expressed through library services first.
- App-side views and screen models should call shared APIs instead of
  reconstructing the behavior directly.
- Schema versioning stays reviewable because `NormleSchemaV1` and
  `NormleSchemaMigrationPlan` remain library-owned contracts.
