#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/common.sh

fn_nix_system_from_expression() {
  local expression=${1:?"Nix expression is required"}
  local -a known=(
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  )

  for system in "${known[@]}"; do
    case "$expression" in
      *".${system}"|*".${system}."*) echo "$system"; return ;;
    esac
  done

  echo "Cannot extract system from expression ${expression}" >&2
  exit 1
}

fn_nix_build() {
  # Check if any arguments were provided
  if [ $# -eq 0 ]; then
    echo "Nix expression is required" >&2
    return 1
  fi

  local passthrough_args=("${@:1:$#-1}")
  local expression="${!#}"

  local current_system
  current_system=$(nix config show --json | jq -re '.system.value')

  local expression_system
  expression_system=$(fn_nix_system_from_expression "${expression}") || exit $?
  
  if [[ "${expression_system}" == "${current_system}" ]]; then
    echo "Building locally since the desired system of '${current_system}' matches the local system" >&2
    local out_path
    out_path=$(nix build "${passthrough_args[@]}" --no-link --json "${expression}" | jq -re '.[0].outputs.out')
    echo "${out_path}"
  else
    local builder
    builder=$(grep -v '#' /etc/nix/machines | grep "${expression_system}" | awk '{print $1}') || fn_fatal "No linux builder found for ${expression_system}"

    echo "Using remote builder '${builder}'" >&2
    local out_path
    out_path=$(nix build "${passthrough_args[@]}" --json --builders "" --eval-store auto --store "${builder}" "${passthrough_args[@]}" "${expression}" 2> >(grep -v "^evaluating file '.*'$" >&2) | \
      jq -re '.[0].outputs.out') || fn_fatal "Failed to build image"

    echo "Copying result from ${builder} to local store: ${out_path}" >&2
    nix copy --from "${builder}" "${out_path}"
    echo "${out_path}"
  fi
}