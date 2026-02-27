# Normle macOS DMG Release Guide

## Overview

`ci_scripts/build_normle_dmg.sh` builds a release DMG from a pre-exported
`Normle.app`.

Flow:

1. Run release gates:
   iOS build, macOS build, and `NormleLibrary` tests.
2. Validate the provided app path, signature, and CloudKit entitlements.
3. Create a DMG (`Normle_<version>.dmg`) with `Normle.app` and `/Applications`.
4. Notarize and staple.

Current policy for direct DMG distribution:

1. macOS builds distributed by DMG treat subscription-gated features as enabled.
2. iCloud sync remains user-configurable in Settings.

## One-Time Setup: notarytool Keychain Profile

Run this once on the release machine:

```sh
xcrun notarytool store-credentials "NormleNotary" \
  --apple-id "<APPLE_ID>" \
  --team-id "66PKF55HK5" \
  --password "<APP_SPECIFIC_PASSWORD>"
```

## Command

The command format is fixed:

```sh
bash ci_scripts/build_normle_dmg.sh "/path/to/Normle.app"
```

The app must already be signed with `Developer ID Application`.
The script will fail if any pre-release gate fails.

Output file:

```text
release/artifacts/Normle_<CFBundleShortVersionString>.dmg
```

The script does not overwrite an existing DMG with the same name.

## Troubleshooting

### 1. App Is Not Signed for Distribution

Symptom:

1. The script fails with `Exported app is not signed with Developer ID Application`.

Fix:

1. Re-export `Normle.app` for direct distribution (Developer ID), then rerun.

### 2. notarytool Profile Is Not Registered

Symptom:

1. Log includes `No Keychain password item found for profile`.

Fix:

```sh
xcrun notarytool store-credentials "NormleNotary" \
  --apple-id "<APPLE_ID>" \
  --team-id "66PKF55HK5" \
  --password "<APP_SPECIFIC_PASSWORD>"
```

Then rerun the same command.

### 3. Notarization Fails

Symptom:

1. `notarytool submit --wait` exits with a non-zero status.

Fix:

1. Check the printed notary log under `release/logs`.
2. Resolve the reported issue.
3. Rerun the script.
