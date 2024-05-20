{ deno
, denort
, writeShellScriptBin
, runCommand
, makeWrapper
}:
let
  deno-app-build-src = ./.;
  deno-app-build = runCommand "deno-app-build"
    {
      __noChroot = true;
      nativeBuildInputs = [ deno makeWrapper ];
    }
    ''
      mkdir -p $out/bin $out/cache
      export DENO_DIR=$(mktemp -d)
      export TEST_PATH=$(mktemp -d)
      export DENORT_BIN="${denort}/bin/denort"
      deno compile -A --check --output=$out/bin/deno-app-build ${deno-app-build-src}/build.ts
      wrapProgram "$out/bin/deno-app-build" --set DENO_WASM_CACHE_HOME "$out/cache"
      echo "import { assert } from 'jsr:@std/assert@0.221.0'; assert(true);" > "$TEST_PATH/test.ts"
      $out/bin/deno-app-build --app-path="$TEST_PATH/test.ts" --out-path="$TEST_PATH/out"
    '';
in
deno-app-build
