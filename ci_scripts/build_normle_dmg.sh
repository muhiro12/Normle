#!/usr/bin/env bash
set -euo pipefail

script_name=$(basename "$0")
default_notary_profile="NormleNotary"
notary_profile="$default_notary_profile"
exported_app_path=""

releases_directory=""
dmg_log_path=""
notary_log_path=""
staple_log_path=""
final_dmg_path=""

usage() {
  cat <<EOF
Usage: $script_name "/path/to/Normle.app"
EOF
}

print_result_summary() {
  if [[ -n "$releases_directory" ]]; then
    echo "Release directory: $releases_directory"
  fi

  if [[ -n "$final_dmg_path" && -f "$final_dmg_path" ]]; then
    echo "DMG artifact: $final_dmg_path"
  fi

  if [[ -n "$dmg_log_path" && -f "$dmg_log_path" ]]; then
    echo "DMG log: $dmg_log_path"
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

if [[ $# -ne 1 ]]; then
  echo "Exactly one argument is required." >&2
  usage >&2
  exit 2
fi

exported_app_path="$1"
if [[ "$exported_app_path" != /* ]]; then
  exported_app_path="$(pwd)/$exported_app_path"
fi

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repository_root=$(cd "$script_directory/.." && pwd)
cd "$repository_root"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  fail "This script must run inside a git repository."
fi

echo "Running release gates before DMG packaging."
bash ci_scripts/build_normle.sh
bash ci_scripts/test_normle_library.sh
echo "Release gates passed."

required_commands=(
  "xcrun"
  "hdiutil"
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

if [[ ! -d "$exported_app_path" ]]; then
  fail "Provided exported app was not found: $exported_app_path"
fi

app_info_plist_path="$exported_app_path/Contents/Info.plist"
if [[ ! -f "$app_info_plist_path" ]]; then
  fail "Info.plist was not found in exported app: $app_info_plist_path"
fi

short_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$app_info_plist_path" 2>/dev/null || true)
if [[ -z "$short_version" ]]; then
  fail "Failed to read CFBundleShortVersionString from $app_info_plist_path"
fi

app_signing_authority=$(codesign -dv --verbose=4 "$exported_app_path" 2>&1 | awk -F= '/^Authority=/{print $2; exit}' || true)
if [[ "$app_signing_authority" != Developer\ ID\ Application:* ]]; then
  fail "Exported app is not signed with Developer ID Application. Found: ${app_signing_authority:-unknown}"
fi

releases_directory="$repository_root/release"
artifacts_directory="$releases_directory/artifacts"
logs_directory="$releases_directory/logs"
run_timestamp=$(date +%Y%m%d-%H%M%S)
dmg_log_path="$logs_directory/dmg-${run_timestamp}.log"
notary_log_path="$logs_directory/notary-${run_timestamp}.log"
staple_log_path="$logs_directory/staple-${run_timestamp}.log"
staging_directory="$repository_root/build/ci/tmp/dmg-staging-${run_timestamp}"

mkdir -p "$artifacts_directory" "$logs_directory"

cleanup() {
  if [[ -d "$staging_directory" ]]; then
    rm -rf "$staging_directory"
  fi
}

trap cleanup EXIT

final_dmg_base_path="$artifacts_directory/Normle_${short_version}"
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

echo "Submitting DMG for notarization with profile: $notary_profile"
if ! xcrun notarytool submit \
  "$final_dmg_path" \
  --wait \
  --keychain-profile "$notary_profile" >"$notary_log_path" 2>&1; then
  if grep -q "No Keychain password item found for profile" "$notary_log_path"; then
    echo "Notary profile '$notary_profile' was not found in Keychain." >&2
    echo "Create it once, then rerun this script:" >&2
    echo "xcrun notarytool store-credentials \"$notary_profile\" --apple-id <APPLE_ID> --team-id 66PKF55HK5 --password <APP_SPECIFIC_PASSWORD>" >&2
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
