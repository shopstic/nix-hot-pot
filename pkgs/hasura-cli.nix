{ lib, fetchurl, stdenv, makeWrapper }:
let
  version = "2.38.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-amd64";
      hash = "sha256-0r0tnroJo6ttx1jjb9hx7Cay3oTQ27EBTK2jNvOEcDo=";
    };
    aarch64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-arm64";
      hash = "sha256-XWqUIOz7+x945R/Ly7uqiAlkrHAcAfYT9bEDff8ls/Q=";
    };
    aarch64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-arm64";
      hash = "sha256-42OfLIvL6lkVctmjN/oXdgKvB+sQYucnrJ+VQj62MAM=";
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
