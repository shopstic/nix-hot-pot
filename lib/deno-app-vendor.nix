{ name
, cache-entry-file
, config-file
, lock-file
, deno
, nodejs
, jq
, runCommand
, preVendor ? ""
, postVendor ? ""
}:
runCommand "${name}-vendor"
{
  nativeBuildInputs = [ deno nodejs jq ];
  __noChroot = true;
} ''
  export DENO_DIR=$(mktemp -d)
  export WORK_DIR=$(mktemp -d)
  mkdir $out
  shopt -s globstar
  ${preVendor}
  cp ${cache-entry-file} "$WORK_DIR/cache-entry.ts"
  cp ${config-file} "$WORK_DIR/deno.json"
  cp ${lock-file} "$WORK_DIR/deno.lock"
  
  cd "$WORK_DIR"
  deno cache --node-modules-dir --vendor cache-entry.ts

  PACKAGE_JSON=$(npm ls --depth=0 --json | \
    jq -re '
      .dependencies
      | map_values(.version)
      | with_entries(select(.value != null))
      | { dependencies: . }'
  ) || exit 1

  echo "$PACKAGE_JSON" | tee $out/package.json
  
  mv ./node_modules $out/
  mv ./vendor $out/
  ${postVendor}
''
