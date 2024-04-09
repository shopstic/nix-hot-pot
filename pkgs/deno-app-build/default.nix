{ deno
, denort
, writeShellScriptBin
, runCommand
}:
let
  deno-app-build-src = ./build.ts;
  deno-app-build = runCommand "deno-app-build"
    {
      __noChroot = true;
      nativeBuildInputs = [ deno ];
    }
    ''
      mkdir -p $out/bin
      export DENO_DIR=$(mktemp -d)
      export DENORT_BIN="${denort}/bin/denort"
      deno compile -A --check --output=$out/bin/deno-app-build ${deno-app-build-src}
    '';
in 
deno-app-build
