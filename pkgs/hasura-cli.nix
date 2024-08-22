{ lib, fetchurl, stdenv, makeWrapper }:
let
  version = "2.42.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-amd64";
      hash = "sha256-tkHPioLb7UM3/Q3PL2FtX7OCChPtgbprpr8mjKHCzCs=";
    };
    aarch64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-arm64";
      hash = "sha256-m8JJzoY94xWtSbgKkn8Qi3lj/7umw5hmdk8R3w1wrfc=";
    };
    aarch64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-arm64";
      hash = "sha256-mfkEheuhZ4U5nLSr0tyykZOiZAY6rQ6WQHoMXlsuDNA=";
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
