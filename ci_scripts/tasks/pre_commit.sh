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

cache_directory="$repository_root/.build/ci/shared/cache"
pre_commit_home="$repository_root/.build/ci/shared/pre-commit"
mkdir -p "$cache_directory" "$pre_commit_home"

fallback_pre_commit_home="${HOME}/.cache/pre-commit"
if [[ -d "$fallback_pre_commit_home" ]] && ! compgen -G "$pre_commit_home/repo*" >/dev/null; then
  cp -R "$fallback_pre_commit_home"/. "$pre_commit_home"/
fi

if ! command -v pre-commit >/dev/null 2>&1; then
  echo "pre-commit is not installed. Install it and retry." >&2
  echo "Install with: pipx install pre-commit or brew install pre-commit" >&2
  exit 1
fi

echo "Running pre-commit checks..."
XDG_CACHE_HOME="$cache_directory" \
PRE_COMMIT_HOME="$pre_commit_home" \
pre-commit run --all-files
