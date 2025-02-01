{ name
, src
, denoConfigPath ? null
, deno-ship
, genCacheEntryArgs ? ""
, runCommand
, writeTextFile
}:
let
  cache-entry = runCommand "${name}-cache-entry"
    {
      nativeBuildInputs = [ deno-ship ];
    } ''
    mkdir $out
    export DENO_DIR=$(mktemp -d)
    time deno-ship gen-cache-entry --src-path="${src}" ${if denoConfigPath != null then ''--deno-config-path="${src}/${denoConfigPath}"'' else ""} ${genCacheEntryArgs} > "$out/cache-entry.ts"
  '';
in
writeTextFile {
  name = "${name}-cache-entry.ts";
  text = builtins.readFile "${cache-entry}/cache-entry.ts";
}
