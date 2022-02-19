{ fetchurl, stdenv }:
let
  version = "2.2.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-amd64";
      hash = "sha256-Xzzb0AJXJB9gYgaqET4UINI7uQ0wSnD6oe1nGZEhSKU=";
    };
    x86_64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-amd64";
      hash = "sha256-LO6yvE9fbsG7nBgxJ3Td+La38bTKHVQAPjPHXhp2mqg=";
    };
    aarch64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-arm64";
      hash = "sha256-s2PL+d7/jf+sT7iTh+7WRJ/0/7RZfjl6TX6CN5lTMH8=";
    };
    aarch64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-arm64";
      hash = "sha256-3zr7Q7WPF9fyojfbjZ2P1EM/TmbqFhogfoZ7QU7tNok=";
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
