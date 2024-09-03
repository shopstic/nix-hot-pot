{ deno
, lib
, denort
, writeShellScriptBin
, runCommand
, makeWrapper
}:
let
  deno-app-build-src = builtins.path
    {
      path = ./..;
      name = "deno-app-build-src";
      filter = with lib; (path: /* type */_:
        hasInfix "/deno-app-build" path ||
        hasInfix "/_deno-shared" path
      );
    };
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
      
      deno compile -A --check --frozen --output=$out/bin/deno-app-build ${deno-app-build-src}/deno-app-build/build.ts

      wrapProgram "$out/bin/deno-app-build" --set DENO_WASM_CACHE_HOME "$out/cache" --add-flags build
      echo "import { assert } from 'jsr:@std/assert@1.0.0'; assert(true);" > "$TEST_PATH/test.ts"
      $out/bin/deno-app-build --app-path="$TEST_PATH/test.ts" --out-path="$TEST_PATH/out"
    '';
in
deno-app-build
