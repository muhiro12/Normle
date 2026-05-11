# Normle Architecture Guide

## Scope

This guide defines the strict `domain-in-library, UI-as-adapter` policy for
Normle.

Related document:
[shared-service-design.md](./shared-service-design.md)

Related decisions:

- [0001-shared-library-source-of-truth.md](../Decisions/0001-shared-library-source-of-truth.md)
- [0002-platform-adapters-stay-in-app-target.md](../Decisions/0002-platform-adapters-stay-in-app-target.md)
- [0003-views-own-presentation-not-business-rules.md](../Decisions/0003-views-own-presentation-not-business-rules.md)
- [0004-non-destructive-verification-gate.md](../Decisions/0004-non-destructive-verification-gate.md)

## Responsibility Boundaries

| Layer | Owns | Must not own |
| --- | --- | --- |
| Domain (`NormleLibrary`) | Transform rules, masking and restore logic, mapping transfer formats, SwiftData models, persistence rules, preference-backed value types | App lifecycle wiring, `ModelContainer` fallback policy, TipKit invalidation, file import/export UI flow, alert presentation |
| Adapter (`Normle`) | `ModelContainer` creation, CloudKit on/off fallback, runtime bootstrap, route intake, mutation workflow wiring, TipKit, clipboard, file import/export, destructive reset orchestration | Reimplementing transform, mapping, restore, or persistence rules already owned by `NormleLibrary` |
| View (SwiftUI) | Layout, bindings, sheet/dialog presentation state, transient selection and navigation state, display-only formatting | Direct domain branching, data import/export rules, mutation retry policy, runtime/bootstrap ownership |

## View Rules

Allowed in views:

- layout and section composition
- `@Query`, `@Binding`, and typed environment wiring
- sheet, alert, and confirmation-dialog presentation state
- screen-scoped `@Observable` model ownership through `@State`
- display-only formatting

Not allowed in views:

- direct domain mutation branching
- repeated import/export orchestration
- repeated TipKit invalidation or mutation follow-up policy
- persistence bootstrap or CloudKit fallback decisions

## Screen-Scoped Models

When a screen grows beyond trivial local state, keep a small `@Observable`
screen model in the root view's `@State` and pass bindings into child views.

Current examples:

- `BaseTransformScreenModel`
- `MappingListScreenModel`
- `SettingsScreenModel`
- `RestoreViewModel`
- `NormleNavigationModel`

## Canonical Mutation Flow

`View -> Screen Model / App Adapter -> NormleMutationWorkflow -> NormleLibrary service -> SwiftData write -> Observation / @Query updates`

Adapters may orchestrate reviews, alerts, or reset flows after mutation
completion, but transform and persistence rules stay in `NormleLibrary`.

## SwiftData Boundary

Keep in `NormleLibrary`:

- `@Model` types
- domain services that accept `ModelContext`

Keep in `Normle`:

- `NormleAppModelContainerFactory`
- CloudKit on/off policy and fallback decisions
- preview and smoke-test container creation
- app lifecycle wiring and runtime bootstrap

## Verification Contract

- `bash ci_scripts/tasks/check_environment.sh --profile verify` diagnoses local prerequisites.
- `bash ci_scripts/tasks/format_swift.sh` is the explicit autofix step after Swift edits.
- `bash ci_scripts/tasks/verify_task_completion.sh` is the non-destructive final verification gate.
- `bash ci_scripts/tasks/verify_pre_commit.sh` reruns the same non-destructive gate for `pre-commit`.
- `bash ci_scripts/tasks/verify_repository_state.sh` evaluates local changes and writes CI run artifacts.

SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Normle.xcodeproj`, not from a separately installed `swiftlint` binary.
