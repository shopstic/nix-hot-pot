{ deno
, deno-vendor
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
      nativeBuildInputs = [ deno deno-vendor makeWrapper ];
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
      
      echo '{"imports": {"@std/assert": "jsr:@std/assert@1.0.0"}}' > "$TEST_PATH/deno.json"
      echo "import { assert } from '@std/assert/assert'; assert(true);" > "$TEST_PATH/test.ts"
      $out/bin/deno-app-transpile --src-path="$TEST_PATH" --import-map-path="$TEST_PATH/deno.json"

      TRANSPLIED=$(cat "$TEST_PATH/test.ts")
      if [[ "$TRANSPLIED" != "import { assert } from \"jsr:/@std/assert@1.0.0/assert\""* ]]; then
        echo "$TRANSPLIED"
        echo "Test transpilation failed"
        exit 1
      fi
    '';
in
deno-app-transpile
