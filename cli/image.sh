#!/usr/bin/env bash
set -euo pipefail

fn_image_push() {
  local image_repository=${IMAGE_REPOSITORY:?"IMAGE_REPOSITORY env var is required"}
  local image_push_skip_diffing=${IMAGE_PUSH_SKIP_DIFFING:-"0"}
  local skopeo_copy_parallelism=${SCOPEO_COPY_PARALLELISM:-"20"}
  local skopeo_copy_retry_times=${SCOPEO_COPY_RETRY_TIMES:-"1"}

  local nix_store_path=${1:?"Nix store path is required"}
  local image=${2:?"Image name is required"}
  local image_tag=${3:?"Image tag is required"}
  local arch=${4:?"Arch is required (amd64 | arm64)"}

  local target_image="${image_repository}/${image}:${image_tag}-${arch}"
  local last_image="${image_repository}/${image}:latest-${arch}"

  local last_image_nix_store_path=""
  if [[ "${image_push_skip_diffing}" == "0" ]]; then
    last_image_nix_store_path=$(regctl manifest get --format='{{jsonPretty .}}' "${last_image}" | jq -re '.annotations["nix.store.path"]') || true
  else
    echo "Skipping diffing of last image" >&2
  fi

  if [[ "${last_image_nix_store_path}" == "${nix_store_path}" ]]; then
    echo "Last image ${last_image} already exists with nix.store.path annotation of ${nix_store_path}" >&2
    regctl index create "${target_image}" --ref "${last_image}" --annotation nix.store.path="${nix_store_path}" --platform linux/"${arch}" >&2
  else
    echo "Last image ${last_image} nix.store.path=${last_image_nix_store_path} does not match ${nix_store_path}" >&2
    echo "Pushing image ${target_image}" >&2
    skopeo copy \
      --dest-compress-format="zstd:chunked" \
      --insecure-policy \
      --image-parallel-copies="${skopeo_copy_parallelism}" \
      --retry-times="${skopeo_copy_retry_times}" \
      nix:"${nix_store_path}" \
      docker://"${target_image}" >&2

    local pids=()
    regctl index create "${target_image}" --ref "${target_image}" --annotation nix.store.path="${nix_store_path}" --platform linux/"${arch}" >&2 &
    pids+=($!)
    regctl index create "${last_image}" --ref "${target_image}" --annotation nix.store.path="${nix_store_path}" --platform linux/"${arch}" >&2 &
    pids+=($!)
    wait "${pids[@]}" || exit 1
  fi

  echo "${target_image}"
}

fn_image_push_manifest() {
  local image_repository=${IMAGE_REPOSITORY:?"IMAGE_REPOSITORY env var is required"}
  local image=${1:?"Image name is required"}
  local image_tag=${2:?"Image tag is required"}
  local target="${image_repository}/${image}:${image_tag}"

  echo "Writing manifest for ${target}" >&2
  regctl index create "${target}" \
    --ref "${image_repository}/${image}:${image_tag}-amd64" \
    --ref "${image_repository}/${image}:${image_tag}-arm64" \
    --platform linux/amd64 \
    --platform linux/arm64 >&2
  echo "${target}"
}
