#!/usr/bin/env bash
set -euo pipefail

argument_count=$#
if [[ $argument_count -ne 0 ]]; then
  echo "This script does not accept arguments." >&2
  exit 2
fi

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repository_root=$(cd "$script_directory/.." && pwd)
cd "$repository_root"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This script must run inside a git repository." >&2
  exit 1
fi

changed_files=$(
  {
    git diff --name-only --cached
    git diff --name-only
    git ls-files --others --exclude-standard
  } | sed '/^$/d' | sort -u
)

if [[ -z "$changed_files" ]]; then
  echo "No local changes detected."
  exit 0
fi

needs_normle_build=false
needs_normle_library_tests=false

if grep -Eq '^Normle/|^Normle\.xcodeproj/' <<<"$changed_files"; then
  needs_normle_build=true
fi

if grep -Eq '^NormleLibrary/' <<<"$changed_files"; then
  needs_normle_library_tests=true
fi

if ! $needs_normle_build && ! $needs_normle_library_tests; then
  echo "No changes under Normle/, NormleLibrary/, or Normle.xcodeproj/."
  exit 0
fi

if $needs_normle_build; then
  echo "Running Normle build."
  bash ci_scripts/build_normle.sh
fi

if $needs_normle_library_tests; then
  echo "Running NormleLibrary tests."
  bash ci_scripts/test_normle_library.sh
fi
