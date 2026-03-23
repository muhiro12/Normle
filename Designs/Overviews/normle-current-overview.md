# Normle Current Product and Architecture Overview

Current as of March 23, 2026.

## Purpose

Normle is a SwiftUI text transformation app for iPhone and Mac. It is centered
on reusable transform presets, mapping-based masking, history restore, and
optional CloudKit-backed persistence.

The current implementation is intentionally biased toward one shared domain
library plus one app target:

- `Normle` owns runtime bootstrap, platform adapters, screen models, and UI.
- `NormleLibrary` owns reusable business logic, SwiftData models, schema
  versioning, and persistence rules that accept `ModelContext`.

## Surface Summary

| Surface | Current role | Key responsibilities |
| --- | --- | --- |
| `Normle` | Primary product surface | SwiftUI screens, runtime assembly, `ModelContainer` creation, TipKit, route handling, app alerts, destructive reset orchestration |
| `NormleLibrary` | Shared domain layer | Transform execution, masking rules, mapping transfer, history persistence, restore logic, schema versioning, preference-backed value types |
| `NormleTests` | App integration / smoke surface | Runtime bootstrap smoke test, app-owned container factory tests |

## Current End-User Features

### 1. Transform execution

- Apply ordered transform presets to input text.
- Support QR encode and QR decode flows.
- Persist transform results into history.
- Copy transformed text or QR input/output from the result section.

### 2. Mapping management

- Create, edit, enable, disable, and delete mapping rules.
- Export mappings as JSON.
- Import mappings with replace, merge, or append behavior.
- Seed prefilled mapping creation from selected transform input text.

### 3. History and restore

- Persist transform records in SwiftData.
- Browse previous runs in history.
- Restore prior outputs by replaying stored mappings onto new source text.
- Delete single history entries or clear all history.

### 4. Settings and maintenance

- Surface subscription entry points when premium is unavailable.
- Let subscribed users toggle iCloud sync.
- Reset TipKit education flows.
- Run a full local factory reset that clears data, preferences, tips, pending
  routes, and session state on the device.

## Current Architecture Notes

- `Normle` intentionally adopts the full `MHPlatform` umbrella.
- `NormleLibrary` intentionally adopts `MHPlatformCore`.
- `NormleAppModelContainerFactory` owns CloudKit on/off and fallback decisions.
- `NormleMutationWorkflow` is the app-side mutation adapter that wraps shared
  services with review-flow follow-up behavior.
- Screen-scoped models keep transform, mapping-list, and settings orchestration
  out of the SwiftUI view layer.

## Current Verification Contract

- `check_environment.sh` diagnoses local prerequisites.
- `format_swift.sh` is the explicit autofix step.
- `lint_swift.sh` is non-destructive and uses project-managed SwiftLint.
- `verify_repository_state.sh` runs targeted checks and writes CI run artifacts.
- `verify_task_completion.sh` is the non-destructive final gate.
- `verify_pre_commit.sh` reruns the same final gate for `pre-commit`.
