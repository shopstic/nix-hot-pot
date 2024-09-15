{ deno
, lib
, denort
, writeShellScriptBin
, runCommand
, makeWrapper
}:
let
  src = ./../../deno-app;
  deno-app-transpile = runCommand "deno-app-transpile"
    {
      __noChroot = true;
      nativeBuildInputs = [ deno makeWrapper ];
    }
    ''
      mkdir -p $out/bin $out/cache
      export DENO_DIR=$(mktemp -d)
      export TEST_PATH=$(mktemp -d)
      export DENORT_BIN="${denort}/bin/denort"
      
      deno compile -A --check --frozen --output=$out/bin/deno-app-transpile ${src}/transpile/main.ts

      wrapProgram "$out/bin/deno-app-transpile" \
        --prefix PATH : "${deno}/bin" \
        --set DENO_WASM_CACHE_HOME "$out/cache" \
        --add-flags transpile
      echo "import { assert } from 'jsr:@std/assert@1.0.0'; assert(true);" > "$TEST_PATH/test.ts"
      $out/bin/deno-app-transpile --app-path="$TEST_PATH/test.ts" --out-path="$TEST_PATH/out"
    '';
in
deno-app-transpile
