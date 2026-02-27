# Normle macOS DMG Release Guide

## Overview

`ci_scripts/build_normle_dmg.sh` builds a release DMG from a pre-exported
`Normle.app`.

Flow:

1. Validate the provided app path and signature.
2. Create a DMG (`Normle_<version>.dmg`) with `Normle.app` and `/Applications`.
3. Notarize and staple.

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

Output file:

```text
build/releases/Normle_<CFBundleShortVersionString>.dmg
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

1. Check the printed notary log under `build/releases/logs`.
2. Resolve the reported issue.
3. Rerun the script.
