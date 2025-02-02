#!/usr/bin/env bash
set -euo pipefail
shopt -s extglob globstar

THIS_DIR="$(dirname "$(realpath "$0")")"

code_quality() {
  "$0" check_all
  echo "Checking for unformatted sources"
  deno fmt --check
  echo "Running deno lint..."
  deno lint
}

update_lock() {
  rm -f deno.lock
  "$@" check_all
}

check_all() {
  deno check "$@" ./src/**/*.ts
}

update_deps() {
  deno run -A "$(jq -er '.imports["@wok/deup"]' <deno.json)" update "$@"
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

test_trim_lock_compile() {
  local DENO_DIR=${1:?"Deno directory is required as the first argument"}
  local CONFIG=${2:?"Configuration file is required as the second argument"}
  local LOCK=${3:?"Lock file is required as the third argument"}

  local TEMP_DIR
  TEMP_DIR=$(mktemp -d)
  trap "rm -Rf ${TEMP_DIR}" EXIT

  deno run -A --check "${THIS_DIR}"/src/main.ts trim-lock --deno-dir "${DENO_DIR}" --config "${CONFIG}" --lock "${LOCK}" "${@:4}" | tee "${TEMP_DIR}"/deno.lock
  DENO_DIR="${DENO_DIR}" deno compile --cached-only --frozen --config="${CONFIG}" --lock="${TEMP_DIR}"/deno.lock --output="${TEMP_DIR}/out" "${@:4}"
}

"$@"
