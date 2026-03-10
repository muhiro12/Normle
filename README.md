# Normle

## Overview

Normle is a SwiftUI text transformation app for iPhone and Mac. It applies
reusable mappings and transform presets, keeps history in SwiftData, and can
optionally sync through CloudKit while premium access is coordinated through
StoreKit-backed runtime state.

## Targets

- **Normle** - the iOS and macOS app that hosts the SwiftUI experience,
  platform configuration, and runtime wiring.
- **NormleLibrary** - the shared domain layer containing transform pipelines,
  mapping transfer services, masking and restore logic, history persistence,
  and preference-backed helpers.

## Feature Highlights

- Build reusable transforms from mappings, masking rules, and presets.
- Review previous runs in history and restore prior outputs.
- Transfer mapping rules between devices or environments.
- Control iCloud sync and premium-gated behavior from Settings.

## Architecture And Technologies

- **Shared-library-first design** - core logic lives in
  `NormleLibrary/Sources`, while the app target stays focused on assembly and
  presentation.
- **SwiftData + CloudKit** - the shared library owns model-container creation
  and migration planning for local and cloud-backed stores.
- **App assembly boundary** - `Normle/Sources/NormleAppAssembly.swift` wires
  runtime dependencies and environment injection.
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

Use the helper scripts in `ci_scripts/` as needed. For full local verification:

```sh
bash ci_scripts/tasks/verify.sh
```

If you only need required builds or tests based on local changes:

```sh
bash ci_scripts/tasks/run_required_builds.sh
```

If you only need the app build:

```sh
bash ci_scripts/tasks/build_app.sh
```

If you only need library tests:

```sh
bash ci_scripts/tasks/test_shared_library.sh
```

### CI Artifact Layout

CI helper scripts write generated artifacts under `.build/ci/`. Run-scoped
outputs are stored in `.build/ci/runs/<RUN_ID>/` with `summary.md`,
`commands.txt`, `meta.json`, `logs/`, `results/`, and `work/`. Shared caches
and build state live in `.build/ci/shared/` (`cache/`, `DerivedData/`, `tmp/`,
`home/`).

## Release

- Direct macOS DMG packaging guide: [docs/dmg_release.md](docs/dmg_release.md)
