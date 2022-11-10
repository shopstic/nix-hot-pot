{ fetchurl, stdenv, makeWrapper }:
let
  version = "2.15.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-amd64";
      hash = "sha256-Zx2OkzPZ1ftr6HUFabtcPDn2BAT71aVMzxbcutDLgtQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-arm64";
      hash = "sha256-p4XtHHa8BdIXtW7nUOKD1Zqg8jY0R/qde9jrwksoh9Q=";
    };
    aarch64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-arm64";
      hash = "sha256-Z97xTJCUInR038x5NeFaF8CJagNAqUcFakf8Ef7sxU8=";
    };
  };
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "hasura-cli";

  binary = let download = downloadMap.${stdenv.system}; in
    fetchurl {
      name = "hasura-cli-${version}";
      url = download.url;
      sha256 = download.hash;
    };

  dontUnpack = true;
  dontPatch = true;
  dontStrip = true;
  dontFixup = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -m+x ${binary} $out/bin/hasura
    wrapProgram $out/bin/hasura --add-flags --skip-update-check
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/hasura/graphql-engine/releases;
    description = "Hasura CLI";
    platforms = builtins.attrNames downloadMap;
  };
}
