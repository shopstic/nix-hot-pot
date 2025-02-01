{ deno
, stdenv
, denort
, makeWrapper
}:
let
  name = "deno-ship";
  src = ./.;
in
stdenv.mkDerivation {
  inherit src name;
  nativeBuildInputs = [ makeWrapper deno ];
  __noChroot = true;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase =
    ''
      shopt -s globstar
      export DENO_DIR="$(mktemp -d)"
      mkdir -p $out/bin $out/cache
      DENORT_BIN="${denort}/bin/denort" deno compile -A --check --frozen --output=$out/bin/${name} ./src/main.ts

      wrapProgram "$out/bin/${name}" \
        --set DENO_WASM_CACHE_HOME "$out/cache"

      $out/bin/${name} cache-wasm
    '';
}


