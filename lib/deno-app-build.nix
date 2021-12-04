{ name
, src
, appSrcPath
, stdenv
, deno
, denoRunFlags ? "--no-remote --cached-only --unstable -A"
, writeShellScriptBin
}:
let
  deps = stdenv.mkDerivation
    {
      inherit src;
      name = "${name}-deps";
      nativeBuildInputs = [ deno ];
      __noChroot = true;
      phases = [ "unpackPhase" "installPhase" ];

      installPhase =
        ''
          mkdir $out
          export DENO_DIR=$out
          deno cache --lock=lock.json "${appSrcPath}"
        '';
    };

  jsBundle = stdenv.mkDerivation
    {
      inherit src;
      name = "${name}.js";
      nativeBuildInputs = [ deno ];

      phases = [ "unpackPhase" "installPhase" ];

      installPhase =
        ''
          export DENO_DIR=$(mktemp -d)
          echo "DENO_DIR=$DENO_DIR"
          ln -s ${deps}/deps "$DENO_DIR/"
          cp -R ${deps}/gen "$DENO_DIR/"
          chmod -R +w "$DENO_DIR/gen"
          deno bundle --lock=lock.json "${appSrcPath}" $out
        '';
    };
in
writeShellScriptBin name ''
  exec ${deno}/bin/deno run ${denoRunFlags} "${jsBundle}" "$@"
''
