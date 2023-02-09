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
  deno cache --lock=deno.lock "${DIR_PATH}"/src/intellij-helper.ts
}

update_lock() {
  rm -f deno.lock
  deno cache --reload "${DIR_PATH}"/src/intellij-helper.ts
  deno cache "${DIR_PATH}"/src/intellij-helper.ts --lock "${DIR_PATH}"/deno.lock --lock-write
}

"$@"