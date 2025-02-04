#!/usr/bin/env bash
set -euo pipefail

image_arch_to_nix_arch() {
  local IMAGE_ARCH=${1:?"Image arch is required (amd64 | arm64)"}

  if [[ "${IMAGE_ARCH}" == "arm64" ]]; then
    echo "aarch64"
  elif [[ "${IMAGE_ARCH}" == "amd64" ]]; then
    echo "x86_64"
  else
    echo >&2 "Invalid image arch of ${IMAGE_ARCH}"
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

  parallel -j6 --tagstring "[{}]" --line-buffer --retries=5 \
    "$0" push_single_arch {} "${IMAGE_ARCH}" ::: "${IMAGES[@]}"

  # docker image prune -f
}

push_all_manifests() {
  readarray -t IMAGES < <(find ./images -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  parallel -j8 --tagstring "[{}]" --line-buffer --retries=5 \
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

  echo >&2 "Pushing ${TARGET_IMAGE}"

  skopeo --insecure-policy copy --dest-tls-verify=false --dest-compress-format="zstd:chunked" \
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

  echo >&2 "Writing manifest for ${TARGET}"

  manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template "${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}-ARCH" \
    --target "${TARGET}"
}

nix_copy_to_public_bin_cache() {
  NIX_CACHE_BUCKET_NAME=${NIX_CACHE_BUCKET_NAME:?"NIX_CACHE_BUCKET_NAME env var is required"}
  PACKAGE_ARCH=${1:?"Package arch is required"}
  PACKAGE_NAME=${2:?"Package name is required"}
  PACKAGE_VERSION=${3:?"Package version is required"}
  PACKAGE_PATH=$(nix path-info ".#packages.${PACKAGE_ARCH}.${PACKAGE_NAME}-${PACKAGE_VERSION}") || exit $?

  DESTINATION="${PACKAGE_NAME}/${PACKAGE_VERSION}/${PACKAGE_ARCH}"
  S3_DESTINATION="s3://${NIX_CACHE_BUCKET_NAME}/bin/${DESTINATION}"

  if ! aws s3 ls "${S3_DESTINATION}" >/dev/null 2>&1; then
    echo "Uploading ${DESTINATION} to bin cache"
    aws s3 cp "${PACKAGE_PATH}/bin/"* "${S3_DESTINATION}/"
  else
    echo "${DESTINATION} already exists in bin cache, skipping..."
  fi
}

"$@"
