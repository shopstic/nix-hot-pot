{ name
, src
, appSrcPath
, denoRunFlags ? "--no-config --no-lock --no-prompt --no-remote --cached-only -A"
, stdenv
, deno
, deno-app-build
, deno-cache ? null
, writeShellScriptBin
}:
let
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
          RESULT=$(${deno-app-build}/bin/deno-app-build "${appSrcPath}" $out) || exit $?
          echo "$RESULT" > $entry
        '';
    };
in
writeShellScriptBin name ''
  exec ${deno}/bin/deno run ${denoRunFlags} "$(cat ${app-build.entry})" "$@"
''
