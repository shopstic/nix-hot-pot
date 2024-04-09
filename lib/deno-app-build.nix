{ name
, src
, appSrcPath
, denoRunFlags ? "--no-config --no-lock --no-prompt --no-remote --cached-only -A"
, stdenv
, deno
, deno-app-build
, writeShellScriptBin
, lib
}:
let
  app-build = stdenv.mkDerivation
    {
      inherit src;
      name = "${name}-build";
      nativeBuildInputs = [ deno ];
      __noChroot = true;
      phases = [ "unpackPhase" "installPhase" ];
      installPhase =
        ''
          export DENO_DIR=$(mktemp -d)
          mkdir $out
          ${deno-app-build}/bin/deno-app-build "${appSrcPath}" $out
        '';
    };
  replaceTsExtension = str:
    if lib.hasSuffix ".ts" str then
      lib.substring 0 (lib.stringLength str - 3) str + ".js"
    else
      str;
in
writeShellScriptBin name ''
  exec ${deno}/bin/deno run ${denoRunFlags} "${app-build}/${replaceTsExtension appSrcPath}" "$@"
''
