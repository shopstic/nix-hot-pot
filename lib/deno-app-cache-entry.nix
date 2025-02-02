{ name
, src
, denoConfigPath ? null
, deno-ship
, genCacheEntryArgs ? ""
, runCommand
, preGen ? ""
, postGen ? ""
, writeTextFile
}:
let
  cache-entry = runCommand "${name}-cache-entry"
    {
      nativeBuildInputs = [ deno-ship ];
    } ''
    mkdir $out
    export DENO_DIR=$(mktemp -d)
    ${preGen}
    time deno-ship gen-cache-entry --src-dir="${src}" ${if denoConfigPath != null then ''--config="${src}/${denoConfigPath}"'' else ""} ${genCacheEntryArgs} > "$out/cache-entry.ts"
    ${postGen}
  '';
in
writeTextFile {
  name = "${name}-cache-entry.ts";
  text = builtins.readFile "${cache-entry}/cache-entry.ts";
}
