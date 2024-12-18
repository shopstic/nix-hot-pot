{ lib
, name
, src
, appSrcPath
, additionalSrcPaths ? { }
, denoRunFlags ? "--no-config --no-lock --no-prompt --no-remote --cached-only -A"
, stdenv
, deno
, deno-vendor
, deno-app-transpile
, deno-cache-dir ? null
, preBuild ? ""
, postBuild ? ""
, preExec ? ""
, writeShellScriptBin
, allowNpmSpecifiers ? false
, prefix-patch ? null
, suffix-patch ? null
}:
let
  generateBuildCommands = outputVarName: srcPath: ''
    ${outputVarName}=$(${deno-app-transpile}/bin/deno-app-transpile --app-path="${srcPath}" --out-path="$out"${if allowNpmSpecifiers then " --allow-npm-specifier" else ""}) || exit $?
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
      nativeBuildInputs = [ deno deno-vendor ];
      __noChroot = deno-cache-dir == null;
      phases = [ "unpackPhase" "installPhase" ];
      outputs = [ "out" "entry" ];
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
  ${preExec}
  exec ${deno}/bin/deno run ${denoRunFlags} "$(cat ${app-build.entry})" "$@"
''
