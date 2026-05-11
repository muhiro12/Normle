#!/usr/bin/env bash
set -euo pipefail

argument_count=$#
if [[ $argument_count -ne 0 ]]; then
  echo "This script does not accept arguments." >&2
  exit 2
fi

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repository_root=$(cd "$script_directory/../.." && pwd)
cd "$repository_root"

mhplatform_remote_base="https://github.com/muhiro12/MHPlatform"
status=0

print_failure() {
  local message=$1
  local details=${2:-}

  echo "MHPlatform boundary violation: ${message}" >&2
  if [[ -n "$details" ]]; then
    echo "$details" >&2
  fi
  status=1
}

collect_matches() {
  local pattern=$1
  shift

  rg -n "$pattern" "$@" || true
}

normalize_remote_url() {
  local remote_url=$1

  printf '%s\n' "${remote_url%.git}"
}

mhplatform_package_block=$(sed -n '/github.com\/muhiro12\/MHPlatform/,+3p' NormleLibrary/Package.swift)
mhplatform_project_block=$(
  sed -n '/XCRemoteSwiftPackageReference "MHPlatform"/,+7p' Normle.xcodeproj/project.pbxproj
)
package_remote_url=$(
  sed -En 's/.*url:[[:space:]]*"([^"]*github\.com\/muhiro12\/MHPlatform(\.git)?)".*/\1/p' \
    NormleLibrary/Package.swift | head -n 1
)
project_remote_url=$(
  sed -n '/XCRemoteSwiftPackageReference "MHPlatform"/,+7p' Normle.xcodeproj/project.pbxproj |
    sed -En 's/[[:space:]]*repositoryURL = "([^"]+)";/\1/p' |
    head -n 1
)

package_path_hits=$(
  collect_matches \
    '\.package\(.*path:\s*"[^"]*MHPlatform' \
    NormleLibrary/Package.swift
)
if [[ -n "$package_path_hits" ]]; then
  print_failure \
    "Local path MHPlatform package dependencies are forbidden." \
    "$package_path_hits"
fi

project_path_hits=$(
  collect_matches \
    'repositoryURL = "(file://|/|\.\./).*MHPlatform' \
    Normle.xcodeproj/project.pbxproj
)
if [[ -n "$project_path_hits" ]]; then
  print_failure \
    "Local path MHPlatform Xcode package references are forbidden." \
    "$project_path_hits"
fi

if [[ -n "$mhplatform_package_block" ]] && grep -Eq 'branch:\s*"|\.branch\("' <<<"$mhplatform_package_block"; then
  print_failure \
    "Floating MHPlatform branch dependencies are forbidden in Package.swift." \
    "$mhplatform_package_block"
fi

if [[ -n "$mhplatform_project_block" ]] && grep -Eq 'kind = branch;' <<<"$mhplatform_project_block"; then
  print_failure \
    "Floating MHPlatform branch dependencies are forbidden in the Xcode project." \
    "$mhplatform_project_block"
fi

library_umbrella_hits=$(
  collect_matches \
    'product\(name:\s*"(MHPlatform|MHAppRuntime|MHDeepLinking|MHLogging|MHNotificationPlans|MHNotificationPayloads|MHRouteExecution|MHPersistenceMaintenance|MHPreferences|MHMutationFlow|MHReviewPolicy)"\s*,\s*package:\s*"MHPlatform"\)' \
    NormleLibrary/Package.swift
)
if [[ -n "$library_umbrella_hits" ]]; then
  print_failure \
    "NormleLibrary must adopt MHPlatformCore instead of direct MHPlatform app-facing or advanced products." \
    "$library_umbrella_hits"
fi

project_umbrella_hits=$(
  collect_matches \
    'productName = MHPlatform;|/\* MHPlatform in Frameworks \*/' \
    Normle.xcodeproj/project.pbxproj
)
if [[ -z "$project_umbrella_hits" ]]; then
  print_failure \
    "The Xcode project must link the MHPlatform umbrella product." \
    "$(rg -n 'MHPlatform|MHAppRuntime|MHLogging|MHPreferences|MHDeepLinking|MHRouteExecution|MHPersistenceMaintenance|MHMutationFlow|MHReviewPolicy' Normle.xcodeproj/project.pbxproj || true)"
fi

project_direct_product_hits=$(
  collect_matches \
    'productName = (MHAppRuntime|MHLogging|MHPreferences|MHDeepLinking|MHRouteExecution|MHPersistenceMaintenance|MHMutationFlow|MHReviewPolicy);|/\* (MHAppRuntime|MHLogging|MHPreferences|MHDeepLinking|MHRouteExecution|MHPersistenceMaintenance|MHMutationFlow|MHReviewPolicy) in Frameworks \*/' \
    Normle.xcodeproj/project.pbxproj
)
if [[ -n "$project_direct_product_hits" ]]; then
  print_failure \
    "The app target must adopt MHPlatform instead of direct MHPlatform concrete products." \
    "$project_direct_product_hits"
fi

app_narrow_import_hits=$(
  collect_matches \
    '^import MH(AppRuntime|Logging|Preferences|DeepLinking|RouteExecution|PersistenceMaintenance|MutationFlow|ReviewPolicy)$' \
    Normle/Sources \
    -g '*.swift'
)
if [[ -n "$app_narrow_import_hits" ]]; then
  print_failure \
    "App target sources must import MHPlatform instead of narrow MHPlatform modules." \
    "$app_narrow_import_hits"
fi

library_invalid_import_hits=$(
  collect_matches \
    '^import (MHPlatform|MHAppRuntime|MHDeepLinking|MHLogging|MHNotificationPlans|MHNotificationPayloads|MHRouteExecution|MHPersistenceMaintenance|MHPreferences|MHMutationFlow|MHReviewPolicy)$' \
    NormleLibrary/Sources \
    -g '*.swift'
)
if [[ -n "$library_invalid_import_hits" ]]; then
  print_failure \
    "NormleLibrary sources must import MHPlatformCore instead of direct MHPlatform app-facing or advanced modules." \
    "$library_invalid_import_hits"
fi

if [[ -z "$package_remote_url" ]] || \
  [[ "$(normalize_remote_url "$package_remote_url")" != "$mhplatform_remote_base" ]]; then
  print_failure \
    "NormleLibrary/Package.swift must reference the MHPlatform GitHub remote." \
    "${mhplatform_package_block:-Expected remote base: ${mhplatform_remote_base}}"
fi

if [[ -z "$mhplatform_package_block" ]] || \
  ! grep -Eq '"1\.0\.0"\.\.<"2\.0\.0"' <<<"$mhplatform_package_block" || \
  grep -Eq 'revision:\s*"|\.revision\("' <<<"$mhplatform_package_block"; then
  print_failure \
    "NormleLibrary/Package.swift must require MHPlatform with the 1.x SemVer range." \
    "${mhplatform_package_block:-$(sed -n '1,120p' NormleLibrary/Package.swift)}"
fi

library_core_dependency_hits=$(
  collect_matches \
    'product\(name:\s*"MHPlatformCore"\s*,\s*package:\s*"MHPlatform"\)' \
    NormleLibrary/Package.swift
)
if [[ -z "$library_core_dependency_hits" ]]; then
  print_failure \
    "NormleLibrary/Package.swift must adopt MHPlatformCore." \
    "$(sed -n '1,120p' NormleLibrary/Package.swift)"
fi

if [[ -z "$project_remote_url" ]] || [[ "$project_remote_url" != "$package_remote_url" ]]; then
  print_failure \
    "Normle.xcodeproj must use the MHPlatform remote declared by NormleLibrary/Package.swift." \
    "Package.swift: ${package_remote_url:-missing}
Xcode project: ${project_remote_url:-missing}"
fi

if [[ -z "$mhplatform_project_block" ]] || \
  ! grep -Eq 'kind = upToNextMajorVersion;' <<<"$mhplatform_project_block" || \
  ! grep -Eq 'minimumVersion = 1\.0\.0;' <<<"$mhplatform_project_block" || \
  grep -Eq 'kind = revision;|revision = [0-9a-f]{40};' <<<"$mhplatform_project_block"; then
  print_failure \
    "Normle.xcodeproj must require MHPlatform with the 1.x SemVer range." \
    "${mhplatform_project_block:-$(rg -n 'MHPlatform|kind = upToNextMajorVersion|minimumVersion =' Normle.xcodeproj/project.pbxproj || true)}"
fi

for resolved_file in \
  "NormleLibrary/Package.resolved" \
  "Normle.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
do
  mhplatform_block=$(sed -n '/"identity" : "mhplatform"/,+8p' "$resolved_file")

  if [[ -z "$mhplatform_block" ]]; then
    print_failure \
      "${resolved_file} must contain an MHPlatform pin." \
      "$(sed -n '1,200p' "$resolved_file")"
    continue
  fi

  resolved_remote_url=$(
    sed -En 's/[[:space:]]*"location"[[:space:]]:[[:space:]]"([^"]+)".*/\1/p' <<<"$mhplatform_block" |
      head -n 1
  )
  if [[ -z "$resolved_remote_url" ]] || \
    [[ "$(normalize_remote_url "$resolved_remote_url")" != "$(normalize_remote_url "$package_remote_url")" ]]; then
    print_failure \
      "${resolved_file} must resolve MHPlatform from the Package.swift remote." \
      "Package.swift: ${package_remote_url:-missing}
${resolved_file}: ${resolved_remote_url:-missing}"
  fi

  if ! grep -Eq '"revision" : "[0-9a-f]{40}"' <<<"$mhplatform_block"; then
    print_failure \
      "${resolved_file} must include the resolved MHPlatform revision." \
      "$mhplatform_block"
  fi

  if ! grep -Eq '"version" : "[^"]+"' <<<"$mhplatform_block"; then
    print_failure \
      "${resolved_file} must record the resolved MHPlatform version." \
      "$mhplatform_block"
  fi

  if grep -Eq '"branch" :' <<<"$mhplatform_block"; then
    print_failure \
      "${resolved_file} must not float MHPlatform on a branch." \
      "$mhplatform_block"
  fi
done

if [[ $status -ne 0 ]]; then
  exit "$status"
fi

echo "MHPlatform boundaries passed."
