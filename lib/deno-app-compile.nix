{ name
, src
, appSrcPath
, stdenv
, deno
, denoRunFlags ? "--cached-only --unstable -A"
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

  output = stdenv.mkDerivation
    {
      inherit src name;
      nativeBuildInputs = [ deno ];

      phases = [ "unpackPhase" "installPhase" ];

      installPhase =
        ''
          export DENO_DIR=$(mktemp -d)
          echo "DENO_DIR=$DENO_DIR"
          ln -s ${deps}/deps "$DENO_DIR/"
          cp -R ${deps}/gen "$DENO_DIR/"
          chmod -R +w "$DENO_DIR/gen"
          mkdir -p $out/bin
          deno compile --lock=lock.json ${denoRunFlags} --output=$out/bin/${name} "${appSrcPath}" 
        '';
    };
in
output
