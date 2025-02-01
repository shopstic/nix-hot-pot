{ name
, cache-entry-file
, config-file
, lock-file ? null
, deno
, runCommand
, preCache ? ""
, postCache ? ""
}:
runCommand "${name}-cache"
{
  nativeBuildInputs = [ deno ];
  __noChroot = true;
} ''
  export DENO_DIR="$out"
  mkdir -p "$DENO_DIR"

  ${preCache}
  cp --reflink=auto ${cache-entry-file} "./cache-entry.ts"
  chmod +w "./cache-entry.ts"
  cp --reflink=auto ${config-file} "./deno.json"
  ${if lock-file != null then ''cp --reflink=auto ${lock-file} "./deno.lock"'' else ""}

  deno check --lock=deno.lock ./cache-entry.ts
  ${postCache}
''
