{ name
, src
, appSrcPath
, denoCompileFlags ? "--no-config --no-lock --no-prompt --no-remote --cached-only -A"
, stdenv
, deno
, denort
, deno-app-build
}:
stdenv.mkDerivation
{
  inherit src;
  name = "${name}-build";
  nativeBuildInputs = [ deno ];
  __noChroot = true;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    export DENO_DIR=$(mktemp -d)
    TEMP_OUT=$(mktemp -d)
    mkdir -p $out/bin
    RESULT=$(${deno-app-build}/bin/deno-app-build "${appSrcPath}" "$TEMP_OUT") || exit $?
    export DENORT_BIN="${denort}/bin/denort"
    deno compile ${denoCompileFlags} -o "$out/bin/${name}" "$RESULT"
  '';
}
