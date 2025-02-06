#!/usr/bin/env bash
set -euo pipefail

image_arch_to_nix_arch() {
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

build_all_images() {
  local arch=${1:?"Arch is required (amd64 | arm64)"}

  local nic_arch
  nic_arch=$("$0" image_arch_to_nix_arch "${arch}") || exit $?

  nix build -L -v ".#packages.${nic_arch}-linux.all-images"
}

push_all_single_arch_images() {
  local image_arch=${1:?"Arch is required (amd64 | arm64)"}
  readarray -t IMAGES < <(find ./images -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  parallel -j4 --tagstring "[{}]" --line-buffer --retries=5 \
    "$0" push_single_arch {} "${image_arch}" ::: "${IMAGES[@]}"
}

push_all_manifests() {
  readarray -t IMAGES < <(find ./images -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  parallel -j8 --tagstring "[{}]" --line-buffer --retries=5 \
    "$0" push_manifest {} ::: "${IMAGES[@]}"
}

push_single_arch() {
  local image_repository=${IMAGE_REPOSITORY:?"IMAGE_REPOSITORY env var is required"}
  local image_push_skip_diffing=${IMAGE_PUSH_SKIP_DIFFING:-"0"}

  local image=${1:?"Image name is required"}
  local arch=${2:?"Arch is required (amd64 | arm64)"}

  local nic_arch
  nic_arch=$("$0" image_arch_to_nix_arch "${arch}") || exit $?

  local image_tag
  image_tag=$(nix eval --raw ".#packages.${nic_arch}-linux.image-${image}.imageTag") || exit $?

  local file_name
  file_name=$(nix eval --raw ".#packages.${nic_arch}-linux.image-${image}.name") || exit $?

  local target_image="${image_repository}/${image}:${image_tag}-${arch}"
  local last_image="${image_repository}/${image}:latest-${arch}"

  local nix_store_path
  nix_store_path=$(realpath "./result/${file_name}")

  local last_image_nix_store_path=""
  if [[ "${image_push_skip_diffing}" == "0" ]]; then
    last_image_nix_store_path=$(regctl manifest get --format='{{jsonPretty .}}' "${last_image}" | jq -r '.annotations["nix.store.path"]') || true
  else
    echo "Skipping diffing of last image" >&2
  fi

  if [[ "${last_image_nix_store_path}" == "${nix_store_path}" ]]; then
    echo "Last image ${last_image} already exists with nix.store.path annotation of ${nix_store_path}"
    regctl index create "${target_image}" --ref "${last_image}" --annotation nix.store.path="${nix_store_path}" --platform linux/"${arch}"
  else
    echo "Last image ${last_image} nix.store.path=${last_image_nix_store_path} does not match ${nix_store_path}"
    echo "Pushing image ${target_image}"
    skopeo copy --dest-compress-format="zstd:chunked" --insecure-policy nix:"${nix_store_path}" docker://"${target_image}"
    regctl index create "${target_image}" --ref "${target_image}" --annotation nix.store.path="${nix_store_path}" --platform linux/"${arch}"
    regctl index create "${last_image}" --ref "${target_image}" --annotation nix.store.path="${nix_store_path}" --platform linux/"${arch}"
  fi
}

push_manifest() {
  local image_repository=${IMAGE_REPOSITORY:?"IMAGE_REPOSITORY env var is required"}
  local image=${1:?"Image name is required"}
  local image_tag

  local nic_arch
  nic_arch=$(uname -m) || exit $?
  if [[ "${nic_arch}" == "arm64" ]]; then
    nic_arch="aarch64"
  fi

  image_tag=$(nix eval --raw ".#packages.${nic_arch}-linux.image-${image}.imageTag") || exit $?

  local target="${image_repository}/${image}:${image_tag}"

  echo >&2 "Writing manifest for ${target}"
  regctl index create "${target}" \
    --ref "${image_repository}/${image}:${image_tag}-amd64" \
    --ref "${image_repository}/${image}:${image_tag}-arm64" \
    --platform linux/amd64 \
    --platform linux/arm64
  regctl index create "${image_repository}/${image}:latest" \
    --ref "${target}" \
    --platform linux/amd64 \
    --platform linux/arm64
}

"$@"
