{ lib, fetchurl, stdenv, makeWrapper }:
let
  version = "2.41.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-amd64";
      hash = "sha256-McN4kgvaBhB/975nyIjkyTyTQ7byxI/RT2vYySiPL0I=";
    };
    aarch64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-arm64";
      hash = "sha256-8fDBNg0L95GNNw8TaXpDUPMw9Yf5if1+eyTTbgm6TV0=";
    };
    aarch64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-arm64";
      hash = "sha256-nuVokJ75Dphk79ikgXitZ1U9dy5Ij3x3mXf3rdalKD4=";
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

  meta = {
    homepage = "https://github.com/hasura/graphql-engine/releases";
    description = "Hasura CLI";
    license = lib.licenses.asl20;
    platforms = builtins.attrNames downloadMap;
  };
}
