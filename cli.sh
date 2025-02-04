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
  local LAST_IMAGE="${IMAGE_REPOSITORY}/${IMAGE}:latest-${ARCH}"

  local NIX_STORE_PATH
  NIX_STORE_PATH=$(realpath "./result/${FILE_NAME}")

  local LAST_IMAGE_NIX_STORE_PATH
  LAST_IMAGE_NIX_STORE_PATH=$(regctl manifest get --format='{{jsonPretty .}}' "${LAST_IMAGE}" | jq -r '.annotations["nix.store.path"]') || true

  if [[ "${LAST_IMAGE_NIX_STORE_PATH}" == "${NIX_STORE_PATH}" ]]; then
    echo "Last image ${LAST_IMAGE} already exists with nix.store.path annotation of ${NIX_STORE_PATH}"
    regctl index create "${TARGET_IMAGE}" --ref "${LAST_IMAGE}" --annotation nix.store.path="${NIX_STORE_PATH}"
  else
    echo "Last image ${LAST_IMAGE} nix.store.path=${LAST_IMAGE_NIX_STORE_PATH} does not match ${NIX_STORE_PATH}"
    echo "Pushing image ${TARGET_IMAGE}"
    skopeo copy --dest-compress-format="zstd:chunked" --insecure-policy nix:"${NIX_STORE_PATH}" docker://"${TARGET_IMAGE}"
    regctl index create "${TARGET_IMAGE}" --ref "${TARGET_IMAGE}" --annotation nix.store.path="${NIX_STORE_PATH}"
    regctl index create "${LAST_IMAGE}" --ref "${TARGET_IMAGE}" --annotation nix.store.path="${NIX_STORE_PATH}"
  fi
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
  regctl index create "${TARGET}" \
    --ref "${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}-amd64" \
    --ref "${IMAGE_REPOSITORY}/${IMAGE}:${IMAGE_TAG}-arm64"
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
