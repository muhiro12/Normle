# Normle

## Overview

Normle is a SwiftUI text transformation app for iPhone and Mac. It applies
reusable mappings and transform presets, keeps history in SwiftData, and can
optionally sync through CloudKit while premium access is coordinated through
StoreKit-backed runtime state.

## Targets

- **Normle** - the iOS and macOS app that hosts the SwiftUI experience,
  platform configuration, runtime wiring, and the default full-platform
  `MHPlatform` consumer surface.
- **NormleLibrary** - the shared domain layer containing transform pipelines,
  mapping transfer services, masking and restore logic, history persistence,
  preference-backed helpers, and the shared-library-safe `MHPlatformCore`
  consumer surface.

## Feature Highlights

- Build reusable transforms from mappings, masking rules, and presets.
- Review previous runs in history and restore prior outputs.
- Transfer mapping rules between devices or environments.
- Control iCloud sync and premium-gated behavior from Settings.

## Architecture And Technologies

- Related docs:
  [Designs/Architecture/ARCHITECTURE_GUIDE.md](Designs/Architecture/ARCHITECTURE_GUIDE.md)
  and [Designs/Overviews/normle-current-overview.md](Designs/Overviews/normle-current-overview.md)
- **Shared-library-first design** - core logic lives in
  `NormleLibrary/Sources`, while the app target stays focused on assembly and
  presentation.
- **MHPlatform consumer split** - the app target adopts `MHPlatform`, while
  `NormleLibrary` stays on `MHPlatformCore` so shared code stops at the
  core-safe platform surface.
- **App-owned persistence bootstrap** - `Normle` owns `ModelContainer`
  construction, CloudKit fallback, previews, and smoke-test containers, while
  `NormleLibrary` owns the SwiftData model types and persistence rules.
- **App assembly boundary** - `Normle/Sources/NormleAppAssembly.swift` wires
  runtime dependencies and environment injection.
- **Screen-scoped adapters** - transform, mapping, and settings screens use
  small `@Observable` screen models so the views stay presentation-focused.
- **Scripted verification** - helper scripts under `ci_scripts/tasks/` provide
  stable entrypoints for local verification and automation.

## Requirements

- Xcode 16 or later with the iOS 18 and macOS 15 SDKs installed.
- An Apple Developer account configured for CloudKit and StoreKit if you want
  to run with production capabilities.

## Setup

1. Clone the repository and open the project directory.
2. Review `Normle/Configurations/Secret.swift` and replace the default product
   or iCloud identifiers if you are shipping a fork.
3. Open `Normle.xcodeproj`, select the **Normle** scheme, and run on an iOS 18
   simulator or a macOS 15 machine.

## Build And Test

Use the helper scripts in `ci_scripts/` as needed. The repository contract is:
Direct entrypoints live in `ci_scripts/tasks/`, shared shell helpers live in
`ci_scripts/lib/`, and `ci_scripts/ci_post_clone.sh` is reserved for external
post-clone CI setup.

- `bash ci_scripts/tasks/check_environment.sh --profile <format|build|verify>`
  diagnoses missing local prerequisites before tool-dependent flows.
- `bash ci_scripts/tasks/format_swift.sh` is the explicit SwiftLint autofix
  step to run after Swift edits and before the final verification gate.
- `bash ci_scripts/tasks/verify_task_completion.sh` is the non-destructive
  verification gate for task completion.
- `bash ci_scripts/tasks/verify_pre_commit.sh` reruns the same non-destructive
  verification gate for Git `pre-commit` and manual final rechecks.
- `bash ci_scripts/tasks/verify_repository_state.sh` checks the current
  repository state and still writes CI run artifacts.

SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Normle.xcodeproj`. The repository scripts do not require a separately
installed `swiftlint` binary on your `PATH`.

Before running the full verify gate, diagnose the local prerequisites:

```sh
bash ci_scripts/tasks/check_environment.sh --profile verify
```

After Swift edits, run the explicit autofix step:

```sh
bash ci_scripts/tasks/format_swift.sh
```

Then run the non-destructive full recheck:

```sh
bash ci_scripts/tasks/verify_task_completion.sh
```

For release-time verification or a clean-worktree full run, force the standard
verify entrypoint to execute all required checks:

```sh
CI_RUN_FORCE_FULL=1 bash ci_scripts/tasks/verify_task_completion.sh
```

If you only need the final pre-commit recheck shell:

```sh
bash ci_scripts/tasks/verify_pre_commit.sh
```

If you only need required builds or tests based on local changes:

```sh
bash ci_scripts/tasks/verify_repository_state.sh
```

If you want Git's `pre-commit` hook to enforce the same repository flow,
install `pre-commit` in your local environment and run `pre-commit install`.
The hook delegates to `bash ci_scripts/tasks/verify_pre_commit.sh` through the
local `.pre-commit-config.yaml`.

The scripts below are optional targeted helpers, not standardized repository
entrypoints.

If you only need the app build:

```sh
bash ci_scripts/tasks/build_app.sh
```

If you only need app tests:

```sh
bash ci_scripts/tasks/test_app.sh
```

If you only need library tests:

```sh
bash ci_scripts/tasks/test_shared_library.sh
```

If you prefer to run the SwiftLint steps directly:

```sh
bash ci_scripts/tasks/format_swift.sh
bash ci_scripts/tasks/lint_swift.sh
```

### CI Artifact Layout

CI helper scripts write generated artifacts under `.build/ci/`. Run-scoped
outputs are stored in `.build/ci/runs/<RUN_ID>/` with `summary.md`,
`commands.txt`, `meta.json`, `logs/`, `results/`, and `work/`. Shared caches
and build state live in `.build/ci/shared/` (`cache/`, `DerivedData/`, `tmp/`,
`home/`).

## Release

- Direct macOS DMG packaging guide: [docs/dmg_release.md](docs/dmg_release.md)
