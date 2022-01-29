#!/usr/bin/env bash
set -euo pipefail

patch_module_iml() {
  local MODULE_NAME=${1?"Module name is required"}
  local MODULE_PREFIX=${2?"Module prefix is required"}
  local IML_MODULE_PATH="./.idea/modules/${MODULE_NAME}.iml"

  if [[ ! -f "${IML_MODULE_PATH}" ]]; then
    echo "${IML_MODULE_PATH} doesn't exist, skipping"
    exit 0
  fi

  local EXCLUDE_FOLDER_TYPE
  EXCLUDE_FOLDER_TYPE=$(faq -f xml -o json -r '.module.component.content.excludeFolder | type' "${IML_MODULE_PATH}")
  local TO_APPEND="{\"-url\":\"file://\$MODULE_DIR\$/../../${MODULE_PREFIX}${MODULE_NAME}/target\"}"

  echo "Patching ${IML_MODULE_PATH}"
  case $EXCLUDE_FOLDER_TYPE in
  object)
    faq -f xml -o xml -r \
      ".module.component.content.excludeFolder = ([.module.component.content.excludeFolder, ${TO_APPEND}] | unique_by(.[\"-url\"]))" "${IML_MODULE_PATH}" \
      | sponge "${IML_MODULE_PATH}"
    ;;

  array)
    faq -f xml -o xml -r \
      ".module.component.content.excludeFolder = ([.module.component.content.excludeFolder[], ${TO_APPEND}] | unique_by(.[\"-url\"]))" "${IML_MODULE_PATH}" \
      | sponge "${IML_MODULE_PATH}"
    ;;

  *)
    faq -f xml -o xml -r \
      ".module.component.content.excludeFolder = ${TO_APPEND}" "${IML_MODULE_PATH}" \
      | sponge "${IML_MODULE_PATH}"
    ;;
  esac
}

patch_module_iml_all() {
  local MODULE_PREFIX=${1?"Module prefix is required"}

  find . -maxdepth 1 -type d -name "${MODULE_PREFIX}*" | sed -e "s/^\.\/${MODULE_PREFIX}//" | xargs -I{} "$0" patch_module_iml {} "${MODULE_PREFIX}"
}

"$@"
