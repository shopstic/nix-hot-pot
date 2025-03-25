#!/usr/bin/env bash
set -euo pipefail
shopt -s extglob globstar

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# shellcheck disable=SC1090
for file in "${SCRIPT_DIR}"/cli/*.sh; do source "$file"; done

fn_image_arch_to_nix_arch() {
  local image_arch=${1:?"Image arch is required (amd64 | arm64)"}

  if [[ "${image_arch}" == "arm64" ]]; then
    echo "aarch64"
  elif [[ "${image_arch}" == "amd64" ]]; then
    echo "x86_64"
  else
    echo >&2 "Invalid image arch of ${image_arch}"
    exit 1
  fi
}

fn_build_all_images() {
  local arch=${1:?"Arch is required (amd64 | arm64)"}

  local nix_arch
  nix_arch=$(fn_image_arch_to_nix_arch "${arch}")

  local out_path
  out_path=$(fn_nix_build -L ".#packages.${nix_arch}-linux.all-images")
  echo "Linking ${out_path} to ./result" >&2
  if [[ -e ./result ]]; then
    rm -f ./result
  fi
  ln -s "${out_path}" ./result
}

fn_push_all_single_arch_images() {
  local image_arch=${1:?"Arch is required (amd64 | arm64)"}
  readarray -t IMAGES < <(find ./images -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  parallel -j2 --tagstring "[{}]" --line-buffer --retries=2 \
    "$0" fn_push_single_arch {} "${image_arch}" ::: "${IMAGES[@]}"
}

fn_push_all_manifests() {
  readarray -t IMAGES < <(find ./images -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  parallel -j8 --tagstring "[{}]" --line-buffer --retries=5 \
    "$0" fn_push_manifest {} ::: "${IMAGES[@]}"
}

fn_push_single_arch() {
  local image=${1:?"Image name is required"}
  local arch=${2:?"Arch is required (amd64 | arm64)"}

  local nix_arch
  nix_arch=$(fn_image_arch_to_nix_arch "${arch}")

  local image_tag
  image_tag=$(nix eval --raw ".#packages.${nix_arch}-linux.image-${image}.imageTag")

  local file_name
  file_name=$(nix eval --raw ".#packages.${nix_arch}-linux.image-${image}.name")

  local nix_store_path
  nix_store_path=$(realpath "./result/${file_name}")

  fn_image_push "${nix_store_path}" "${image}" "${image_tag}" "${arch}"
}

fn_push_manifest() {
  local image=${1:?"Image name is required"}

  local current_system
  current_system=$(nix config show --json | jq -re '.system.value')

  local image_tag
  image_tag=$(nix eval --raw ".#packages.${current_system}.image-${image}.imageTag")

  local target
  target=$(fn_image_push_manifest "${image}" "${image_tag}")

  local target_latest="${target%%:*}:latest"
  regctl image copy "${target}" "${target_latest}"
}

"$@"
