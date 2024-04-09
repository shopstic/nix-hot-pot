{ name
, src
, appSrcPath
, denoCompileFlags ? "--no-config --no-lock --no-prompt --no-remote --cached-only -A"
, stdenv
, deno
, denort
, deno-app-build
, lib
}:
let
  replaceTsExtension = str:
    if lib.hasSuffix ".ts" str then
      lib.substring 0 (lib.stringLength str - 3) str + ".js"
    else
      str;
in
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
    ${deno-app-build}/bin/deno-app-build "${appSrcPath}" "$TEMP_OUT"
    export DENORT_BIN="${denort}/bin/denort"
    deno compile ${denoCompileFlags} -o "$out/bin/${name}" "$TEMP_OUT/${replaceTsExtension appSrcPath}"
  '';
}
