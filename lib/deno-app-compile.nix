{ lib
, name
, src
, appSrcPath
, additionalSrcPaths ? { }
, transpile ? false
, denoCompileFlags ? (if transpile then "--no-config --no-lock --no-prompt --no-remote --cached-only -A" else "--cached-only -A")
, stdenv
, makeWrapper
, deno
, denort
, deno-app-transpile
, deno-cache-dir ? null
, deno-vendor-dir ? null
, preBuild ? ""
, postBuild ? ""
, postCompile ? ""
, prefix-patch ? null
, suffix-patch ? null
}:
let
  generateBuildCommands = outputVarName: srcPath: ''
    ${outputVarName}=${if transpile then 
    ''$(deno-app-transpile --allow-npm-specifier --app-path="${srcPath}" --out-path="$TEMP_OUT") || exit $?''
    else
    ''"${srcPath}"''}

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
  nativeBuildInputs = [ makeWrapper deno deno-app-transpile ];
  __noChroot = deno-cache-dir == null;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase =
    ''
      export DENO_DIR=$(mktemp -d)
      ${
        if deno-cache-dir != null 
        then 
        ''
          ln -s ${deno-cache-dir}/deps "$DENO_DIR/deps"
          ln -s ${deno-cache-dir}/npm "$DENO_DIR/npm"
          ln -s ${deno-cache-dir}/registries "$DENO_DIR/registries"
        '' 
        else ""
      }

      ${
        if deno-vendor-dir != null 
        then 
        ''
          cp -r "${deno-vendor-dir}"/* .
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


