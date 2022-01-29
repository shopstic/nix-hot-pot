#!/usr/bin/env bash
set -euo pipefail

build_push_images() {
  readarray -t IMAGES < <(find ./images -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  parallel -j2 --tagstring "[{}]" --line-buffer --retries=2 \
    "$0" build_push_multi_arch {} ::: "${IMAGES[@]}"
}

build_push_multi_arch() {
  local IMAGE=${1:?"Image name is required"}
  local IMAGE_TAG
  IMAGE_TAG=$(nix eval --raw ".#packages.x86_64-linux.image-${IMAGE}.imageTag") || exit $?

  parallel -j2 --tagstring "[{}]" --line-buffer --retries=2 \
    "$0" build_push_single_arch "${IMAGE}" {} "${IMAGE_TAG}" ::: \
    amd64 arm64

  "$0" push_manifest "${IMAGE}" "${IMAGE_TAG}"
}

build_push_single_arch() {
  local IMAGE_REPOSITORY=${IMAGE_REPOSITORY:?"IMAGE_REPOSITORY env var is required"}

  local IMAGE=${1:?"Image name is required"}
  local ARCH=${2:?"Arch is required (amd64 | arm64"}
  local IMAGE_TAG=${3:?"Image tag is required"}
  local TEMP_DIR

  TEMP_DIR=$(mktemp -d)
  trap "rm -Rf ${TEMP_DIR}" EXIT

  local NIX_ARCH="x86_64"
  if [[ "${ARCH}" == "arm64" ]]; then
    NIX_ARCH="aarch64"
  fi

  nix build -L -v ".#packages.${NIX_ARCH}-linux.image-${IMAGE}" -o "${TEMP_DIR}/image"

  local TARGET_IMAGE="${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}-${ARCH}"

  >&2 echo "Pushing ${TARGET_IMAGE}"

  skopeo --insecure-policy copy \
    docker-archive:"${TEMP_DIR}/image" \
    "docker://${TARGET_IMAGE}"
}

push_manifest() {
  local IMAGE_REPOSITORY=${IMAGE_REPOSITORY:?"IMAGE_REPOSITORY env var is required"}
  local IMAGE=${1:?"Image name is required"}
  local IMAGE_TAG=${2:?"Image tag is required"}
  local TARGET="${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}"
  
  >&2 echo "Writing manifest for ${TARGET}"

  manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template "${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}-ARCH" \
    --target "${TARGET}"
}

"$@"