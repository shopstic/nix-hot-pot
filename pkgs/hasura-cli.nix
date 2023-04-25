{ fetchurl, stdenv, makeWrapper }:
let
  version = "2.23.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-amd64";
      hash = "sha256-QNxteTGBQ0/NWZ6o0pN/9oEVHPcjmwGKuhijaD/UkMU=";
    };
    aarch64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-arm64";
      hash = "sha256-j7Mux1IQ3uaAwhN753Rt7tTz6PUU8m1X/cUfhke8gH8=";
    };
    aarch64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-arm64";
      hash = "sha256-Cxaw0sGPDkpIbFCt6U4vHiAX4n68hYmM6rypfdwDFdM=";
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
