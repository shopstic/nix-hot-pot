#!/usr/bin/env bash
set -euo pipefail

image_arch_to_nix_arch() {
  local IMAGE_ARCH=${1:?"Image arch is required (amd64 | arm64)"}

  if [[ "${IMAGE_ARCH}" == "arm64" ]]; then
    echo "aarch64"
  elif [[ "${IMAGE_ARCH}" == "amd64" ]]; then
    echo "x86_64"
  else
     >&2 echo "Invalid image arch of ${IMAGE_ARCH}"
     exit 1
  fi
}

build_all_images() {
  local ARCH=${1:?"Arch is required (amd64 | arm64)"}

  local NIX_ARCH
  NIX_ARCH=$("$0" image_arch_to_nix_arch "${ARCH}") || exit $?

  nix build -L -v ".#packages.${NIX_ARCH}-linux.all-images"
}

push_all_single_arch_images() {
  local IMAGE_ARCH=${1:?"Arch is required (amd64 | arm64)"}
  readarray -t IMAGES < <(find ./images -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  parallel -j8 --tagstring "[{}]" --line-buffer --retries=2 \
    "$0" push_single_arch {} "${IMAGE_ARCH}" ::: "${IMAGES[@]}"
}

push_all_manifests() {
  readarray -t IMAGES < <(find ./images -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  parallel -j8 --tagstring "[{}]" --line-buffer --retries=2 \
    "$0" push_manifest {} ::: "${IMAGES[@]}"
}

push_single_arch() {
  local IMAGE_REPOSITORY=${IMAGE_REPOSITORY:?"IMAGE_REPOSITORY env var is required"}

  local IMAGE=${1:?"Image name is required"}
  local ARCH=${2:?"Arch is required (amd64 | arm64)"}
  
  local NIX_ARCH
  NIX_ARCH=$("$0" image_arch_to_nix_arch "${ARCH}") || exit $?

  local IMAGE_TAG
  IMAGE_TAG=$(nix eval --raw ".#packages.${NIX_ARCH}-linux.image-${IMAGE}.imageTag") || exit $?

  local FILE_NAME
  FILE_NAME=$(nix eval --raw ".#packages.${NIX_ARCH}-linux.image-${IMAGE}.name") || exit $?

  local TARGET_IMAGE="${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}-${ARCH}"

  >&2 echo "Pushing ${TARGET_IMAGE}"

  skopeo --insecure-policy copy \
    nix:"./result/${FILE_NAME}" \
    "docker://${TARGET_IMAGE}"
}

push_manifest() {
  local IMAGE_REPOSITORY=${IMAGE_REPOSITORY:?"IMAGE_REPOSITORY env var is required"}
  local IMAGE=${1:?"Image name is required"}
  local IMAGE_TAG

  local NIX_ARCH
  NIX_ARCH=$(uname -m) || exit $?
  if [[ "${NIX_ARCH}" == "arm64" ]]; then
    NIX_ARCH="aarch64"
  fi

  IMAGE_TAG=$(nix eval --raw ".#packages.${NIX_ARCH}-linux.image-${IMAGE}.imageTag") || exit $?

  local TARGET="${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}"
  
  >&2 echo "Writing manifest for ${TARGET}"

  manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template "${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}-ARCH" \
    --target "${TARGET}"
}

"$@"