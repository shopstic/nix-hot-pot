#!/usr/bin/env bash
set -euo pipefail
shopt -s extglob globstar

THIS_DIR="$(dirname "$(realpath "$0")")"

code_quality() {
  deno fmt --check
  deno lint
  deno check **/*.ts
}

update_lock() {
  rm -f deno.lock
  deno cache "${THIS_DIR}"/**/*.ts "$@"
}

update_deps() {
  deno run -A jsr:@wok/deup@2.1.1 update "$@"
  "$0" update_lock
}

test_transpile() {
  local SRC_DIR=${1:?"Source directory is required as the first argument"}
  local IMPORT_MAP_PATH=${2:?"Import map path is required"}
  local TEMP_SRC_DIR

  TEMP_SRC_DIR=$(mktemp -d)
  echo >&2 "Temporary source directory: ${TEMP_SRC_DIR}"
  # trap "rm -Rf ${TEMP_SRC_DIR}" EXIT

  # Copy the source directory to a temporary directory
  rsync -avrx --exclude "*.git" "${SRC_DIR}"/ "${TEMP_SRC_DIR}"/

  deno run -A --check "${THIS_DIR}"/transpile/main.ts transpile --src-path "${TEMP_SRC_DIR}" --import-map-path "${IMPORT_MAP_PATH}" "${@:3}"
}

test_gen_cache_entry() {
  local SRC_DIR=${1:?"Source directory is required as the first argument"}
  deno run -A --check "${THIS_DIR}"/gen_cache_entry/main.ts gen --src-path "${SRC_DIR}" "${@:2}"
}

"$@"
