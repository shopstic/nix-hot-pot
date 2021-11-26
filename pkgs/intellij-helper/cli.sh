#!/usr/bin/env bash
set -euo pipefail

DIR_PATH="$(dirname "$(realpath "$0")")"

code_quality() {
  echo "Checking formatting..."
  deno fmt --unstable --check "${DIR_PATH}/src"
  echo "Linting..."
  deno lint --unstable "${DIR_PATH}/src"
}

update_cache() {
  deno cache --lock=lock.json "${DIR_PATH}"/src/intellij-helper.ts
}

update_lock() {
  deno cache "${DIR_PATH}"/src/intellij-helper.ts --lock "${DIR_PATH}"/lock.json --lock-write
}

"$@"