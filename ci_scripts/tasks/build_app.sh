#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"
source "$script_directory/../lib/xcodebuild.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

echo "Running Normle iOS build."
ci_xcodebuild_run \
  "$repository_root" \
  "Normle.xcodeproj" \
  "Normle" \
  "BuildResults_Normle_iOS" \
  build \
  simulator
echo "Finished Normle iOS build. Result bundle: $CI_XCODEBUILD_LAST_RESULT_BUNDLE_PATH"

echo "Running Normle macOS build."
ci_xcodebuild_run \
  "$repository_root" \
  "Normle.xcodeproj" \
  "Normle" \
  "BuildResults_Normle_macOS" \
  build \
  macos \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO
echo "Finished Normle macOS build. Result bundle: $CI_XCODEBUILD_LAST_RESULT_BUNDLE_PATH"
