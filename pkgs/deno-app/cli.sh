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
  local APP_PATH=${2:?"A app path relative to source directory is required as the second argument"}

  local TEMP_SRC_DIR
  local TEMP_OUT_DIR
  local RESOLVED_APP_PATH

  TEMP_SRC_DIR=$(mktemp -d)
  echo >&2 "Temporary source directory: ${TEMP_SRC_DIR}"
  trap "rm -Rf ${TEMP_SRC_DIR}" EXIT

  TEMP_OUT_DIR=$(mktemp -d)
  echo >&2 "Temporary output directory: ${TEMP_OUT_DIR}"
  trap "rm -Rf ${TEMP_OUT_DIR}" EXIT

  # Copy the source directory to a temporary directory
  rsync -avrx --exclude "*.git" "${SRC_DIR}"/ "${TEMP_SRC_DIR}"/

  RESOLVED_APP_PATH=$(realpath "${TEMP_SRC_DIR}/${APP_PATH}") || exit 1

  (cd "${TEMP_SRC_DIR}" && deno run -A --check "${THIS_DIR}"/transpile/main.ts transpile --app-path "${RESOLVED_APP_PATH}" --out-path "${TEMP_OUT_DIR}" "${@:3}")
}

test_gen_cache_entry() {
  local SRC_DIR=${1:?"Source directory is required as the first argument"}
  deno run -A --check "${THIS_DIR}"/gen_cache_entry/main.ts gen --src-path "${SRC_DIR}" "${@:2}"
}

"$@"
