#!/usr/bin/env bash
set -euo pipefail

get_current_arch() {
  local IMAGE_ARCH
  IMAGE_ARCH=$(uname -m) || exit $?
  if [[ "${IMAGE_ARCH}" == "arm64" ]]; then
  IMAGE_ARCH="aarch64"
  fi
  echo "${IMAGE_ARCH}"
}

build_all_images() {
  local ARCH=${1:?"Arch is required (x86_64 | aarch64)"}
  nix build -L -v ".#packages.${ARCH}-linux.all-images"
}

push_all_single_arch_images() {
  local ARCH=${1:?"Arch is required (amd64 | arm64)"}
  readarray -t IMAGES < <(find ./images -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  parallel -j8 --tagstring "[{}]" --line-buffer --retries=2 \
    "$0" push_single_arch {} "${ARCH}" ::: "${IMAGES[@]}"
}

push_all_manifests() {
  readarray -t IMAGES < <(find ./images -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  parallel -j8 --tagstring "[{}]" --line-buffer --retries=2 \
    "$0" push_manifest {} ::: "${IMAGES[@]}"
}

push_single_arch() {
  local IMAGE_REPOSITORY=${IMAGE_REPOSITORY:?"IMAGE_REPOSITORY env var is required"}

  local IMAGE=${1:?"Image name is required"}
  local ARCH=${2:?"Arch is required (amd64 | arm64"}
  
  local IMAGE_ARCH
  IMAGE_ARCH=$("$0" get_current_arch) || exit $?

  local IMAGE_TAG
  IMAGE_TAG=$(nix eval --raw ".#packages.${IMAGE_ARCH}-linux.image-${IMAGE}.imageTag") || exit $?

  local FILE_NAME
  FILE_NAME=$(nix eval --raw ".#packages.${IMAGE_ARCH}-linux.image-${IMAGE}.name") || exit $?

  local NIX_ARCH="x86_64"
  if [[ "${ARCH}" == "arm64" ]]; then
    NIX_ARCH="aarch64"
  fi

  local TARGET_IMAGE="${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}-${ARCH}"

  >&2 echo "Pushing ${TARGET_IMAGE}"

  skopeo --insecure-policy copy \
    docker-archive:"./result/${FILE_NAME}" \
    "docker://${TARGET_IMAGE}"
}

push_manifest() {
  local IMAGE_REPOSITORY=${IMAGE_REPOSITORY:?"IMAGE_REPOSITORY env var is required"}
  local IMAGE=${1:?"Image name is required"}
  local IMAGE_ARCH
  local IMAGE_TAG

  IMAGE_ARCH=$("$0" get_current_arch) || exit $?
  IMAGE_TAG=$(nix eval --raw ".#packages.${IMAGE_ARCH}-linux.image-${IMAGE}.imageTag") || exit $?

  local TARGET="${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}"
  
  >&2 echo "Writing manifest for ${TARGET}"

  manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template "${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}-ARCH" \
    --target "${TARGET}"
}

"$@"