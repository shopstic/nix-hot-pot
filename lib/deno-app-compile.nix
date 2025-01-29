{ lib
, name
, src
, appSrcPath
, additionalSrcPaths ? { }
, deno-vendor-dir ? null
, denoCompileFlags ? "-A"
, stdenv
, makeWrapper
, deno
, denort
, preBuild ? ""
, postBuild ? ""
, postCompile ? ""
, prefix-patch ? null
, suffix-patch ? null
}:
let
  generateBuildCommands = outputVarName: srcPath: ''
    ${outputVarName}=${''"${srcPath}"''}

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
  __noChroot = deno-vendor-dir == null;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase =
    ''
      export DENO_DIR=$(mktemp -d)

      ${
        if deno-vendor-dir != null 
        then 
        ''
          for dir in deps npm registries; do
            if [ -d ${deno-vendor-dir}/deno-dir/$dir ]; then
              ln -s ${deno-vendor-dir}/deno-dir/$dir "$DENO_DIR/$dir"
            fi
          done

          for link in node_modules vendor; do
            cp -R "${deno-vendor-dir}/$link" "./$link"
          done
        '' 
        else ""
      }

      mkdir -p $out/bin
      ${preBuild}
      ${generateBuildCommands "RESULT" appSrcPath}
      ${lib.strings.concatStringsSep "\n" additionalSrcCommands}
      ${postBuild}
      DENORT_BIN="${denort}/bin/denort" deno compile ${if deno-vendor-dir != null then "--cached-only --vendor --node-modules-dir=manual" else ""} ${denoCompileFlags} -o "$out/bin/${name}" "$RESULT"
      ${postCompile}
    '';
}


