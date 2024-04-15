{ lib
, name
, src
, appSrcPath
, additionalSrcPaths ? { }
, denoCompileFlags ? "--no-config --no-lock --no-prompt --no-remote --cached-only -A"
, stdenv
, makeWrapper
, deno
, denort
, deno-app-build
, deno-cache ? null
, preBuild ? ""
, postBuild ? ""
}:
let
  additionalSrcCommands = lib.mapAttrsToList
    (name: value: ''
      RESULT_${builtins.replaceStrings ["-"] ["_"] (lib.strings.toUpper name)}=$(${deno-app-build}/bin/deno-app-build --allow-npm-specifier --app-path="${value}" --out-path="$TEMP_OUT") || exit $?
    '')
    additionalSrcPaths;
in
stdenv.mkDerivation {
  inherit src name;
  nativeBuildInputs = [ makeWrapper deno ];
  __noChroot = true;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase =
    ''
      export DENO_DIR=$(mktemp -d)
      ${
        if deno-cache != null 
        then 
        ''
          ln -s ${deno-cache}/deps "$DENO_DIR/deps"
          ln -s ${deno-cache}/npm "$DENO_DIR/npm"
          ln -s ${deno-cache}/registries "$DENO_DIR/registries"
        '' 
        else ""
      }
      TEMP_OUT=$(mktemp -d)
      mkdir -p $out/bin
      ${preBuild}
      RESULT=$(${deno-app-build}/bin/deno-app-build --allow-npm-specifier --app-path="${appSrcPath}" --out-path="$TEMP_OUT") || exit $?
      ${lib.strings.concatStringsSep "\n" additionalSrcCommands}
      ${postBuild}
      export DENORT_BIN="${denort}/bin/denort"
      deno compile ${denoCompileFlags} -o "$out/bin/${name}" "$RESULT"
    '';
}


