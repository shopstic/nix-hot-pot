{ lib
, deno
, denort
, writeShellScriptBin
, runCommand
, makeWrapper
, writeTextFile
, diffutils
}:
let
  src = ./../../deno-app;
  test-src = ./test;
  expected-output = writeTextFile {
    name = "expected-output";
    text = ''
      import "jsr:/@std/assert@^1.0.3/assert";
      import "jsr:/@std/assert@^1.0.3/exists";
      import "jsr:/@wok/utils@^1.11.1/exec";
      import "jsr:/@wok/utils@^1.11.1/memoize";
      import "jsr:@std/fmt/colors";
    '';
  };
  deno-gen-cache-entry = runCommand "deno-gen-cache-entry"
    {
      __noChroot = true;
      nativeBuildInputs = [ deno makeWrapper diffutils ];
    }
    ''
      mkdir -p $out/bin $out/cache
      export DENO_DIR=$(mktemp -d)
      export TEST_PATH=$(mktemp -d)
      export DENORT_BIN="${denort}/bin/denort"
      deno compile -A --check --frozen --output=$out/bin/deno-gen-cache-entry "${src}/gen_cache_entry/main.ts"
      wrapProgram "$out/bin/deno-gen-cache-entry" --set DENO_WASM_CACHE_HOME "$out/cache" --add-flags gen
      
      $out/bin/deno-gen-cache-entry --src-path "${test-src}" > "$TEST_PATH/test-output"
      if ! diff "$TEST_PATH/test-output" "${expected-output}"; then
        echo "Test failed"
        exit 1
      fi
    '';
in
deno-gen-cache-entry
