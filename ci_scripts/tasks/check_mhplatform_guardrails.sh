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

package_branch_hits=$(
  collect_matches \
    'branch:\s*"|\.branch\("' \
    NormleLibrary/Package.swift
)
if [[ -n "$package_branch_hits" ]]; then
  print_failure \
    "Floating MHPlatform branch dependencies are forbidden in Package.swift." \
    "$package_branch_hits"
fi

project_branch_hits=$(
  collect_matches \
    'kind = branch;' \
    Normle.xcodeproj/project.pbxproj
)
if [[ -n "$project_branch_hits" ]]; then
  print_failure \
    "Floating MHPlatform branch dependencies are forbidden in the Xcode project." \
    "$project_branch_hits"
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

if ! rg -q "url:\\s*\"${canonical_remote_url//\//\\/}\"" NormleLibrary/Package.swift; then
  print_failure \
    "NormleLibrary/Package.swift must reference the canonical MHPlatform remote." \
    "Expected remote: ${canonical_remote_url}"
fi

if ! rg -q 'revision:\s*"[0-9a-f]{40}"' NormleLibrary/Package.swift; then
  print_failure \
    "NormleLibrary/Package.swift must pin MHPlatform by revision." \
    "$(sed -n '1,120p' NormleLibrary/Package.swift)"
fi

if ! rg -q "repositoryURL = \"${canonical_remote_url//\//\\/}\";" Normle.xcodeproj/project.pbxproj; then
  print_failure \
    "Normle.xcodeproj must reference the canonical MHPlatform remote." \
    "Expected remote: ${canonical_remote_url}"
fi

if ! rg -q 'kind = revision;' Normle.xcodeproj/project.pbxproj || \
  ! rg -q 'revision = [0-9a-f]{40};' Normle.xcodeproj/project.pbxproj; then
  print_failure \
    "Normle.xcodeproj must pin MHPlatform by revision." \
    "$(rg -n 'MHPlatform|kind = revision|revision =' Normle.xcodeproj/project.pbxproj || true)"
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
      "${resolved_file} must pin MHPlatform by revision." \
      "$mhplatform_block"
  fi

  if grep -Eq '"branch" :|"version" :' <<<"$mhplatform_block"; then
    print_failure \
      "${resolved_file} must not float MHPlatform on a branch or version range." \
      "$mhplatform_block"
  fi
done

if [[ $status -ne 0 ]]; then
  exit "$status"
fi

echo "MHPlatform guardrails passed."
