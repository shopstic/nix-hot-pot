{ fetchurl, stdenv }:
let
  version = "2.0.10";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-amd64";
      hash = "sha256-QhEAVgzbpwMhmj4w6s5STuGJ0h/uoJXbn1BHGNnMLBc=";
    };
    x86_64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-amd64";
      hash = "sha256-xOMSsFJGHqQqaxl83F3OI24gJwgAv6Qy0vOSTZG9O68=";
    };
    aarch64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-arm64";
      hash = "sha256-rvg+hYXYJAiksfR1trEtnhMClww33COHBwcyyzRcxCQ=";
    };
    aarch64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-arm64";
      hash = "sha256-xX77cFT+OgGrLKA7otApyiR/ANj8CkxZ8ba5/RvBA2k=";
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

  installPhase = ''
    mkdir -p $out/bin
    install -m+x ${binary} $out/bin/hasura
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/hasura/graphql-engine/releases;
    description = "Hasura CLI";
    platforms = builtins.attrNames downloadMap;
  };
}
