{ name
, src
, denoConfigPath ? null
, deno-gen-cache-entry
, genCacheEntryArgs ? ""
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
    time deno-gen-cache-entry --src-path="${src}" ${if denoConfigPath != null then ''--deno-config-path="${src}/${denoConfigPath}"'' else ""} ${genCacheEntryArgs} > "$out/cache-entry.ts"
  '';
in
writeTextFile {
  name = "${name}-cache-entry.ts";
  text = builtins.readFile "${cache-entry}/cache-entry.ts";
}
