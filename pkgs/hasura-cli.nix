{ lib, fetchurl, stdenv, makeWrapper }:
let
  version = "2.43.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-amd64";
      hash = "sha256-9xZvtjBB4hN/glFCvv2KMY7SojWGdBi1NbXQ9TROiEE=";
    };
    aarch64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-arm64";
      hash = "sha256-f0ZZJ6IAa/psFEkxwRtwtYujBnX6Z3zKuKpzbz02uJk=";
    };
    aarch64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-arm64";
      hash = "sha256-3D9ekOV+YKBjxK1YIojPAoK+QAuluNmDGMlK0fw1Ya8=";
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
