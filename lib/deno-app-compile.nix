{ lib
, name
, src
, appSrcPath
, deno-ship
, stdenv
, makeWrapper
, deno
, denort
, includeSrcPaths ? { }
, deno-cache-dir ? null
, denoCompileFlags ? "-A"
, prePatch ? ""
, postPatch ? ""
, postCompile ? ""
, prefix-patch ? null
, suffix-patch ? null
}:
let
  generatePatchCommands = outputVarName: srcPath: ''
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
    (name: value: (generatePatchCommands ''RESULT_${builtins.replaceStrings ["-"] ["_"] (lib.strings.toUpper name)}'' value))
    includeSrcPaths;
  additionalSrcArgs = lib.strings.concatStringsSep " " (lib.mapAttrsToList
    (name: _: ''"$RESULT_${builtins.replaceStrings ["-"] ["_"] (lib.strings.toUpper name)}"'')
    includeSrcPaths);
  additionalCompileIncludeArgs = lib.strings.concatStringsSep " " (lib.mapAttrsToList
    (name: _: ''--include="$RESULT_${builtins.replaceStrings ["-"] ["_"] (lib.strings.toUpper name)}"'')
    includeSrcPaths);
in
stdenv.mkDerivation {
  inherit src name;
  nativeBuildInputs = [ makeWrapper deno deno-ship ];
  __noChroot = deno-cache-dir == null;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase =
    ''
      shopt -s globstar
      export DENO_DIR="$(mktemp -d)"
      mkdir -p $out/bin

      ${
        if deno-cache-dir != null 
        then 
        ''
          cp ${deno-cache-dir}/*_cache_* "$DENO_DIR"/
          chmod -R +w "$DENO_DIR"
          for dir in deps npm registries remote; do
            if [ -d ${deno-cache-dir}/$dir ]; then
              ln -s ${deno-cache-dir}/$dir "$DENO_DIR/$dir"
            fi
          done
        '' 
        else ""
      }

      ${prePatch}
      ${generatePatchCommands "RESULT" appSrcPath}
      ${lib.strings.concatStringsSep "\n" additionalSrcCommands}
      ${postPatch}
      
      if [ -f "deno.lock" ]; then
        deno-ship trim-lock \
          --deno-dir="$DENO_DIR" \
          --config=$PWD/deno.json \
          --lock=$PWD/deno.lock \
          "$RESULT" ${additionalSrcArgs} > deno.lock
      fi

      DENORT_BIN="${denort}/bin/denort" deno compile \
        ${if deno-cache-dir != null then "--cached-only" else ""} \
        ${denoCompileFlags} \
        ${additionalCompileIncludeArgs} \
        -o "$out/bin/${name}" "$RESULT"

      ${postCompile}
    '';
}


