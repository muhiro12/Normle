# Normle macOS DMG Release Guide

## Overview

Use `ci_scripts/build_normle_dmg.sh` to run this release flow in one command:

1. `xcodebuild archive` for `Normle` (`Release`, `generic/platform=macOS`)
2. `xcodebuild -exportArchive` with `method=developer-id`
3. DMG creation (`Normle.app` + `/Applications` symlink)
4. Notarization (`notarytool submit --wait`)
5. Stapling (`stapler staple`)

Artifacts and logs are stored under `build/releases`.

## One-Time Setup: notarytool Keychain Profile

Run this once on the release machine:

```sh
xcrun notarytool store-credentials "NormleNotary" \
  --apple-id "<APPLE_ID>" \
  --team-id "66PKF55HK5" \
  --password "<APP_SPECIFIC_PASSWORD>"
```

Notes:

1. `<APP_SPECIFIC_PASSWORD>` is an Apple app-specific password.
2. If you use another profile name, pass it with `--notary-profile`.
3. A `Developer ID Application` certificate (with private key) is required for
   direct distribution.

## Standard Release Command

Run the full production flow (archive + DMG + notarization + staple):

```sh
bash ci_scripts/build_normle_dmg.sh
```

Optional:

1. Use a custom Keychain profile:

```sh
bash ci_scripts/build_normle_dmg.sh --notary-profile "CustomProfile"
```

1. Skip notarization and stapling for internal validation:

```sh
bash ci_scripts/build_normle_dmg.sh --skip-notarize
```

Output DMG name:

```text
build/releases/Normle_<CFBundleShortVersionString>.dmg
```

The script does not overwrite an existing DMG with the same name.

## Troubleshooting

### 1. Signing Certificate Is Not Configured

Symptoms:

1. `xcodebuild archive` fails with signing or provisioning errors.
2. `xcodebuild -exportArchive` fails with
   `No signing certificate "Developer ID Application" found`.

Checks:

1. Open Xcode signing settings for `Normle` and confirm the correct team and
   certificate are selected.
2. Validate local identities:

```sh
security find-identity -v -p codesigning
```

3. Confirm that output includes `Developer ID Application: ...`.

### 2. notarytool Profile Is Not Registered

Symptoms:

1. The script reports that the Keychain profile was not found.
2. Log includes `No Keychain password item found for profile`.

Fix:

```sh
xcrun notarytool store-credentials "NormleNotary" \
  --apple-id "<APPLE_ID>" \
  --team-id "66PKF55HK5" \
  --password "<APP_SPECIFIC_PASSWORD>"
```

Then rerun:

```sh
bash ci_scripts/build_normle_dmg.sh
```

### 3. Notarization Fails

Symptoms:

1. `notarytool submit --wait` exits with a non-zero status.

Checks:

1. Open the printed notarization log path under `build/releases/logs`.
2. Fix the reported issue (for example, invalid signature or account access).
3. Rerun the same script command.
