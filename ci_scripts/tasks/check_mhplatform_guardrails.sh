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

canonical_remote_url="https://github.com/muhiro12/MHPlatform.git"
status=0

print_failure() {
  local message=$1
  local details=${2:-}

  echo "MHPlatform guardrail violation: ${message}" >&2
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

mhplatform_package_block=$(sed -n '/url: "https:\/\/github.com\/muhiro12\/MHPlatform\.git"/,+3p' NormleLibrary/Package.swift)
mhplatform_project_block=$(
  sed -n '/XCRemoteSwiftPackageReference "MHPlatform"/,+7p' Normle.xcodeproj/project.pbxproj
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
    'product\(name:\s*"MHPlatform"|dependencies:\s*\[\s*"MHPlatform"\s*\]' \
    NormleLibrary/Package.swift
)
if [[ -n "$library_umbrella_hits" ]]; then
  print_failure \
    "NormleLibrary must not depend on the MHPlatform umbrella product." \
    "$library_umbrella_hits"
fi

project_umbrella_hits=$(
  collect_matches \
    'productName = MHPlatform;|/\* MHPlatform in Frameworks \*/' \
    Normle.xcodeproj/project.pbxproj
)
if [[ -n "$project_umbrella_hits" ]]; then
  print_failure \
    "The Xcode project must not link the MHPlatform umbrella product." \
    "$project_umbrella_hits"
fi

umbrella_import_hits=$(
  collect_matches \
    '^import MHPlatform$' \
    Normle \
    NormleLibrary \
    NormleTests \
    -g '*.swift'
)
if [[ -n "$umbrella_import_hits" ]]; then
  print_failure \
    "Umbrella imports are forbidden. Use narrow MHPlatform modules instead." \
    "$umbrella_import_hits"
fi

if [[ -z "$mhplatform_package_block" ]] || \
  ! grep -Eq "url:\\s*\"${canonical_remote_url//\//\\/}\"" <<<"$mhplatform_package_block"; then
  print_failure \
    "NormleLibrary/Package.swift must reference the canonical MHPlatform remote." \
    "${mhplatform_package_block:-Expected remote: ${canonical_remote_url}}"
fi

if [[ -z "$mhplatform_package_block" ]] || \
  ! grep -Eq '"1\.0\.0"\.\.<"2\.0\.0"' <<<"$mhplatform_package_block" || \
  grep -Eq 'revision:\s*"|\.revision\("' <<<"$mhplatform_package_block"; then
  print_failure \
    "NormleLibrary/Package.swift must require MHPlatform with the 1.x SemVer range." \
    "${mhplatform_package_block:-$(sed -n '1,120p' NormleLibrary/Package.swift)}"
fi

if [[ -z "$mhplatform_project_block" ]] || \
  ! grep -Eq "repositoryURL = \"${canonical_remote_url//\//\\/}\";" <<<"$mhplatform_project_block"; then
  print_failure \
    "Normle.xcodeproj must reference the canonical MHPlatform remote." \
    "${mhplatform_project_block:-Expected remote: ${canonical_remote_url}}"
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

  if ! grep -Eq "\"location\" : \"${canonical_remote_url//\//\\/}\"" <<<"$mhplatform_block"; then
    print_failure \
      "${resolved_file} must resolve MHPlatform from the canonical remote." \
      "$mhplatform_block"
  fi

  if ! grep -Eq '"revision" : "[0-9a-f]{40}"' <<<"$mhplatform_block"; then
    print_failure \
      "${resolved_file} must include the resolved MHPlatform revision." \
      "$mhplatform_block"
  fi

  if ! grep -Eq '"version" : "1\.1\.0"' <<<"$mhplatform_block"; then
    print_failure \
      "${resolved_file} must record MHPlatform version 1.1.0." \
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

echo "MHPlatform guardrails passed."
