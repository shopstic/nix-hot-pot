{ name
, cache-entry-file
, config-file
, lock-file ? null
, deno
, runCommand
, extraDenoInstallArgs ? ""
, preVendor ? ""
, postVendor ? ""
}:
runCommand "${name}-vendor"
{
  nativeBuildInputs = [ deno ];
  __noChroot = true;
} ''
  export DENO_DIR="$out"/deno-dir
  mkdir -p "$DENO_DIR"

  ${preVendor}
  cp ${cache-entry-file} "$out/cache-entry.ts"
  cp ${config-file} "$out/deno.json"
  ${if lock-file != null then ''cp ${lock-file} "$out/deno.lock"'' else ""}
  
  (cd "$out" && deno install --node-modules-dir --vendor ${extraDenoInstallArgs} --entrypoint cache-entry.ts)
  
  rm -Rf "$out/cache-entry.ts" "$out/deno.json" "$out/deno.lock"
  ${postVendor}
''
