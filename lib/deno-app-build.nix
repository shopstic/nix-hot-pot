{ lib
, name
, src
, appSrcPath
, additionalSrcPaths ? { }
, denoRunFlags ? "--no-config --no-lock --no-prompt --no-remote --cached-only -A"
, stdenv
, deno
, deno-app-build
, deno-cache ? null
, preBuild ? ""
, postBuild ? ""
, writeShellScriptBin
, prefix-patch ? null
, suffix-patch ? null
}:
let
  generateBuildCommands = outputVarName: srcPath: ''
    ${outputVarName}=$(${deno-app-build}/bin/deno-app-build --app-path="${srcPath}" --out-path="$TEMP_OUT") || exit $?
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
  app-build = stdenv.mkDerivation
    {
      inherit src;
      name = "${name}-build";
      nativeBuildInputs = [ deno ];
      __noChroot = true;
      phases = [ "unpackPhase" "installPhase" ];
      outputs = [ "out" "entry" ];
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
          mkdir $out
          ${preBuild}
          ${generateBuildCommands "RESULT" appSrcPath}
          ${lib.strings.concatStringsSep "\n" additionalSrcCommands}
          ${postBuild}
          echo "$RESULT" > $entry
        '';
    };
in
writeShellScriptBin name ''
  exec ${deno}/bin/deno run ${denoRunFlags} "$(cat ${app-build.entry})" "$@"
''
