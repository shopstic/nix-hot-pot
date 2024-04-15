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
, postCompile ? ""
, prefix-patch ? null
, suffix-patch ? null
}:
let
  generateBuildCommands = outputVarName: srcPath: ''
    ${outputVarName}=$(${deno-app-build}/bin/deno-app-build --allow-npm-specifier --app-path="${srcPath}" --out-path="$TEMP_OUT") || exit $?
    ${if prefix-patch != null then ''
      PATCHED_${outputVarName}=$(mktemp)
      cat ${prefix-patch} > "$PATCHED_${outputVarName}"
      cat "${"$" + outputVarName}" >> "$PATCHED_${outputVarName}"
      rm "${"$" + outputVarName}"
      mv "$PATCHED_${outputVarName}" "${"$" + outputVarName}"
    '' else ""}

    ${if suffix-patch != null then ''
      PATCHED_${outputVarName}=$(mktemp)
      cat "${"$" + outputVarName}" > "$PATCHED_${outputVarName}"
      cat ${suffix-patch} >> "$PATCHED_${outputVarName}"
      rm "${"$" + outputVarName}"
      mv "$PATCHED_${outputVarName}" "${"$" + outputVarName}"
    '' else ""}
  '';
  additionalSrcCommands = lib.mapAttrsToList
    (name: value: (generateBuildCommands ''RESULT_${builtins.replaceStrings ["-"] ["_"] (lib.strings.toUpper name)}'' value))
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
      ${generateBuildCommands "RESULT" appSrcPath}
      ${lib.strings.concatStringsSep "\n" additionalSrcCommands}
      ${postBuild}
      export DENORT_BIN="${denort}/bin/denort"
      deno compile ${denoCompileFlags} -o "$out/bin/${name}" "$RESULT"
      ${postCompile}
    '';
}


