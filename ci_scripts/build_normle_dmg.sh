#!/usr/bin/env bash
set -euo pipefail

script_name=$(basename "$0")
default_notary_profile="NormleNotary"
notary_profile="$default_notary_profile"
skip_notarize=false

archive_log_path=""
export_log_path=""
dmg_log_path=""
notary_log_path=""
staple_log_path=""
final_dmg_path=""
releases_directory=""

usage() {
  cat <<EOF
Usage: $script_name [--notary-profile <name>] [--skip-notarize]

Options:
  --notary-profile <name>  Keychain profile for notarytool (default: $default_notary_profile)
  --skip-notarize          Skip notarization and stapling
EOF
}

print_result_summary() {
  if [[ -n "$releases_directory" ]]; then
    echo "Release directory: $releases_directory"
  fi

  if [[ -n "$final_dmg_path" && -f "$final_dmg_path" ]]; then
    echo "DMG artifact: $final_dmg_path"
  fi

  if [[ -n "$archive_log_path" && -f "$archive_log_path" ]]; then
    echo "Archive log: $archive_log_path"
  fi

  if [[ -n "$export_log_path" && -f "$export_log_path" ]]; then
    echo "Export log: $export_log_path"
  fi

  if [[ -n "$dmg_log_path" && -f "$dmg_log_path" ]]; then
    echo "DMG log: $dmg_log_path"
  fi

  if $skip_notarize; then
    echo "Notarization: skipped (--skip-notarize)"
    return 0
  fi

  if [[ -n "$notary_log_path" && -f "$notary_log_path" ]]; then
    echo "Notarization log: $notary_log_path"
  fi

  if [[ -n "$staple_log_path" && -f "$staple_log_path" ]]; then
    echo "Staple log: $staple_log_path"
  fi
}

fail() {
  local message="$1"
  echo "$message" >&2
  print_result_summary >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --notary-profile)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --notary-profile." >&2
        usage >&2
        exit 2
      fi
      notary_profile="$2"
      shift 2
      ;;
    --skip-notarize)
      skip_notarize=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$notary_profile" ]]; then
  echo "--notary-profile cannot be empty." >&2
  exit 2
fi

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repository_root=$(cd "$script_directory/.." && pwd)
cd "$repository_root"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  fail "This script must run inside a git repository."
fi

required_commands=(
  "xcodebuild"
  "xcrun"
  "hdiutil"
  "security"
  "codesign"
)

for required_command in "${required_commands[@]}"; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    fail "Required command not found: $required_command"
  fi
done

if [[ ! -x "/usr/libexec/PlistBuddy" ]]; then
  fail "Required command not found: /usr/libexec/PlistBuddy"
fi

project_path="Normle.xcodeproj"
team_id="66PKF55HK5"
derived_data_path="build/DerivedData"
results_directory="build"
releases_directory="$repository_root/build/releases"
archives_directory="$releases_directory/archives"
logs_directory="$releases_directory/logs"

cache_directory="$repository_root/build/xcodebuild_cache"
temporary_directory="$repository_root/build/xcodebuild_tmp"
clang_module_cache_directory="$cache_directory/clang/ModuleCache"
package_cache_directory="$repository_root/build/xcodebuild_package_cache"
cloned_source_packages_directory="$repository_root/build/xcodebuild_source_packages"
swiftpm_cache_directory="$repository_root/build/xcodebuild_swiftpm_cache"
swiftpm_config_directory="$repository_root/build/xcodebuild_swiftpm_config"

mkdir -p \
  "$cache_directory" \
  "$clang_module_cache_directory" \
  "$package_cache_directory" \
  "$cloned_source_packages_directory" \
  "$swiftpm_cache_directory" \
  "$swiftpm_config_directory" \
  "$temporary_directory" \
  "$derived_data_path" \
  "$results_directory" \
  "$releases_directory" \
  "$archives_directory" \
  "$logs_directory"

identity_output=$(security find-identity -v -p codesigning 2>/dev/null || true)
if ! grep -Eq '^[[:space:]]*[0-9]+\) [[:xdigit:]]{40} ' <<<"$identity_output"; then
  fail "No valid code signing identities were found in the current keychain context. Open Xcode once and verify signing, then rerun."
fi

run_timestamp=$(date +%Y%m%d-%H%M%S)
archive_path="$archives_directory/Normle-${run_timestamp}.xcarchive"
archive_log_path="$logs_directory/archive-${run_timestamp}.log"
export_log_path="$logs_directory/export-${run_timestamp}.log"
dmg_log_path="$logs_directory/dmg-${run_timestamp}.log"
notary_log_path="$logs_directory/notary-${run_timestamp}.log"
staple_log_path="$logs_directory/staple-${run_timestamp}.log"
staging_directory="$releases_directory/staging-${run_timestamp}"
export_directory="$releases_directory/export-${run_timestamp}"
export_options_plist_path="$releases_directory/export-options-${run_timestamp}.plist"

cleanup() {
  if [[ -d "$staging_directory" ]]; then
    rm -rf "$staging_directory"
  fi

  if [[ -d "$export_directory" ]]; then
    rm -rf "$export_directory"
  fi

  if [[ -f "$export_options_plist_path" ]]; then
    rm -f "$export_options_plist_path"
  fi
}

trap cleanup EXIT

echo "Creating archive: $archive_path"
if ! TMPDIR="$temporary_directory" \
  XDG_CACHE_HOME="$cache_directory" \
  CLANG_MODULE_CACHE_PATH="$clang_module_cache_directory" \
  SWIFTPM_MODULECACHE_OVERRIDE="$clang_module_cache_directory" \
  SWIFTPM_CACHE_PATH="$swiftpm_cache_directory" \
  SWIFTPM_CONFIG_PATH="$swiftpm_config_directory" \
  xcodebuild \
    -project "$project_path" \
    -scheme "Normle" \
    -configuration "Release" \
    -destination "generic/platform=macOS" \
    -archivePath "$archive_path" \
    -derivedDataPath "$derived_data_path" \
    -resultBundlePath "$results_directory/ArchiveResults_Normle_${run_timestamp}.xcresult" \
    -clonedSourcePackagesDirPath "$cloned_source_packages_directory" \
    -packageCachePath "$package_cache_directory" \
    "CLANG_MODULE_CACHE_PATH=$clang_module_cache_directory" \
    archive >"$archive_log_path" 2>&1; then
  fail "xcodebuild archive failed. See log: $archive_log_path"
fi

archived_app_path="$archive_path/Products/Applications/Normle.app"
app_info_plist_path="$archived_app_path/Contents/Info.plist"

if [[ ! -f "$app_info_plist_path" ]]; then
  fail "Archived app Info.plist was not found: $app_info_plist_path"
fi

short_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$app_info_plist_path" 2>/dev/null || true)

if [[ -z "$short_version" ]]; then
  fail "Failed to read CFBundleShortVersionString from $app_info_plist_path"
fi

cat >"$export_options_plist_path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>developer-id</string>
  <key>signingCertificate</key>
  <string>Developer ID Application</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>teamID</key>
  <string>$team_id</string>
  <key>stripSwiftSymbols</key>
  <true/>
</dict>
</plist>
EOF

mkdir -p "$export_directory"

echo "Exporting archive for Developer ID distribution."
if ! TMPDIR="$temporary_directory" \
  XDG_CACHE_HOME="$cache_directory" \
  xcodebuild \
    -exportArchive \
    -archivePath "$archive_path" \
    -exportPath "$export_directory" \
    -exportOptionsPlist "$export_options_plist_path" >"$export_log_path" 2>&1; then
  if grep -q 'No signing certificate "Developer ID Application" found' "$export_log_path"; then
    echo "Developer ID Application certificate was not found in keychain." >&2
    echo "Install the certificate and private key, then rerun this script." >&2
  fi
  fail "xcodebuild -exportArchive failed. See log: $export_log_path"
fi

exported_app_path="$export_directory/Normle.app"
if [[ ! -d "$exported_app_path" ]]; then
  exported_app_path=$(find "$export_directory" -maxdepth 2 -type d -name "*.app" | head -n 1 || true)
fi

if [[ -z "$exported_app_path" || ! -d "$exported_app_path" ]]; then
  fail "Exported app was not found in $export_directory"
fi

app_signing_authority=$(codesign -dv --verbose=4 "$exported_app_path" 2>&1 | awk -F= '/^Authority=/{print $2; exit}' || true)
if [[ "$app_signing_authority" != Developer\ ID\ Application:* ]]; then
  fail "Exported app is not signed with Developer ID Application. Found: ${app_signing_authority:-unknown}"
fi

final_dmg_base_path="$releases_directory/Normle_${short_version}"
final_dmg_path="${final_dmg_base_path}.dmg"

if [[ -e "$final_dmg_path" ]]; then
  fail "DMG already exists and will not be overwritten: $final_dmg_path"
fi

mkdir -p "$staging_directory"
cp -R "$exported_app_path" "$staging_directory/Normle.app"
ln -s "/Applications" "$staging_directory/Applications"

echo "Creating DMG: $final_dmg_path"
if ! hdiutil create \
  -volname "Normle" \
  -srcfolder "$staging_directory" \
  -fs "HFS+" \
  -format "UDZO" \
  "$final_dmg_base_path" >"$dmg_log_path" 2>&1; then
  fail "DMG creation failed. See log: $dmg_log_path"
fi

if [[ ! -f "$final_dmg_path" ]]; then
  fail "DMG was not created at expected path: $final_dmg_path"
fi

if $skip_notarize; then
  echo "Skipping notarization and stapling because --skip-notarize was specified."
  echo "Normle DMG build finished."
  print_result_summary
  exit 0
fi

echo "Submitting DMG for notarization with profile: $notary_profile"
if ! xcrun notarytool submit \
  "$final_dmg_path" \
  --wait \
  --keychain-profile "$notary_profile" >"$notary_log_path" 2>&1; then
  if grep -q "No Keychain password item found for profile" "$notary_log_path"; then
    echo "Notary profile '$notary_profile' was not found in Keychain." >&2
    echo "Create it once, then rerun this script:" >&2
    echo "xcrun notarytool store-credentials \"$notary_profile\" --apple-id <APPLE_ID> --team-id $team_id --password <APP_SPECIFIC_PASSWORD>" >&2
  else
    echo "Notarization failed. Fix the issue and rerun this script." >&2
  fi
  fail "Notarization failed. See log: $notary_log_path"
fi

echo "Stapling notarization ticket."
if ! xcrun stapler staple "$final_dmg_path" >"$staple_log_path" 2>&1; then
  fail "Stapling failed. See log: $staple_log_path"
fi

echo "Normle DMG release flow finished."
print_result_summary
