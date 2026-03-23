# ADR 0003: Views Own Presentation, Not Business Rules

- Date: 2026-03-23
- Status: Accepted

## Context

SwiftUI views are convenient places to add import/export logic, transform
mutation branching, alert decisions, or TipKit invalidation. Over time that
logic becomes hard to reuse and easy to diverge from other flows.

## Decision

Views own presentation, layout, and dialog state. Reusable app-side
orchestration belongs in screen-scoped `@Observable` models or other adapters.

## Consequences

- `BaseTransformScreenModel`, `MappingListScreenModel`, and
  `SettingsScreenModel` become the adapter layer between views and shared
  services.
- `MappingListView`, `SettingsListView`, and `BaseTransformView` stay focused
  on rendering and presentation bindings.
- If a view starts recreating business logic, that is a refactoring target.
