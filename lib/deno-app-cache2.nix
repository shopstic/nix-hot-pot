{ name
, src
, config-file
, lock-file
, deno
, deno-gen-cache-entry
, genCacheEntryArgs ? ""
, preCache ? ""
, postCache ? ""
, runCommand
, writeTextFile
}:
let
  cache-entry = runCommand "${name}-cache-entry"
    {
      nativeBuildInputs = [ deno-gen-cache-entry ];
    } ''
    mkdir $out
    export DENO_DIR=$(mktemp -d)
    deno-gen-cache-entry --src-path "${src}" ${genCacheEntryArgs} > "$out/cache-entry.ts"
  '';
  cache-entry-ts = writeTextFile {
    name = "${name}-cache-entry.ts";
    text = builtins.readFile "${cache-entry}/cache-entry.ts";
  };
in
runCommand "${name}-cache"
{
  nativeBuildInputs = [ deno ];
  __noChroot = true;
} ''
  mkdir $out
  export DENO_DIR=$out
  ${preCache}
  deno cache --config="${config-file}" --lock="${lock-file}" --frozen=true "${cache-entry-ts}"
  ${postCache}
''
