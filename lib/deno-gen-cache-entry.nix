{ name
, src
, deno-gen-cache-entry
, runCommand
, genCacheEntryArgs ? ""
}:
let
  cache-entry = runCommand "${name}-cache-entry"
    {
      nativeBuildInputs = [ deno-gen-cache-entry ];
    } ''
    mkdir $out
    export DENO_DIR=$(mktemp -d)
    time deno-gen-cache-entry --src-path "${src}" ${genCacheEntryArgs} > "$out/cache-entry.ts"
  '';
in
cache-entry
