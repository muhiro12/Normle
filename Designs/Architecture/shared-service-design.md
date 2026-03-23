# Shared Service Design

## Purpose

This document describes the current boundary for shared business logic in
Normle. It explains where new code should live when the same operation must
work across the transform screen, mapping management, history restore, settings
maintenance, previews, and tests.

## Core Principles

- `NormleLibrary` is the source of truth for reusable business logic.
- `Normle` owns SwiftUI presentation and Apple-framework adapters.
- Screen-scoped `@Observable` models are adapters, not a second domain layer.
- Views keep presentation state and navigation, but reusable mutation and
  transfer rules belong in `NormleLibrary`.
- `NormleLibrary` remains a single module unless there is a stronger reason
  than code organization alone.

## Responsibility Boundaries

| Concern | Lives in | Examples |
| --- | --- | --- |
| Shared domain logic | `NormleLibrary` | `TransformExecutionService`, `TransformPipeline`, `MappingRuleTransferService`, `TransformRecordService`, `RestoreService`, `SubscriptionAccessEvaluator` |
| App-side platform support | `Normle/Sources/Common/Platform` | `NormleAppModelContainerFactory`, `NormlePlatformEnvironmentFactory`, route inbox wiring, runtime bootstrap assembly |
| App-side mutation adapters | `Normle/Sources/Common/Services` and feature screen models | `NormleMutationWorkflow`, `BaseTransformScreenModel`, `MappingListScreenModel`, `SettingsScreenModel`, `NormleFactoryResetCoordinator` |
| Presentation orchestration | `Normle/Sources/*/Views` | SwiftUI view composition, sheet/dialog presentation state, `@Query` wiring, navigation path ownership |

## MHPlatform Adoption

- `Normle` is the intentional `MHPlatform` umbrella adopter.
- `NormleLibrary` adopts `MHPlatformCore` and must not depend on the full
  `MHPlatform` umbrella.
- This repository intentionally uses the MHPlatform 1.x semver range
  `1.0.0..<2.0.0`.

## Canonical Shared APIs

The following types are the current shared entry points for business
operations:

- `TransformExecutionService.runAndSave(...)`
- `TransformRecordService.delete(...)`
- `TransformRecordService.deleteAll(...)`
- `MappingRuleTransferCoordinator.exportData(context:)`
- `MappingRuleTransferCoordinator.loadImportData(from:)`
- `MappingRuleTransferCoordinator.applyImport(data:context:policy:)`
- `SubscriptionAccessEvaluator.evaluate(...)`
- `RestoreService.restore(text:mappings:)`

App-side mutation call sites should prefer `NormleMutationWorkflow` over direct
view-owned orchestration when the action persists or triggers follow-up work.

## Placement Rules

1. If an operation is reusable across more than one screen or app entry point,
   add or extend a library service first.
2. If an operation depends on Apple-only frameworks or app runtime wiring, keep
   it in `Normle`.
3. If a view starts reimplementing transfer, delete-all, transform execution,
   or reset rules, treat that as a missing adapter or library API.
4. Keep `ModelContainer` construction and CloudKit fallback logic out of
   `NormleLibrary`.
5. If glue code is app-only but reused by multiple app entry points, factor it
   into `Normle/Sources/Common`.

## Refactoring Heuristic

When business rules are duplicated, move them into `NormleLibrary`. When the
duplicated code is still app-only orchestration, move it into a screen model or
another app adapter instead of leaving it in the view.
