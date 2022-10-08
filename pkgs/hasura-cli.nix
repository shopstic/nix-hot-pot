{ fetchurl, stdenv }:
let
  version = "2.12.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-amd64";
      hash = "sha256-D61PQ1oNkm6EEuZ4mzMlCCMRYk8hIhMKolZO7Ty+OI0=";
    };
    aarch64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-arm64";
      hash = "sha256-hUd42pWwcqFqXKnokWyvL6K7EYtArVjhEYEWAATzMnM=";
    };
    aarch64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-arm64";
      hash = "sha256-vEvbTpnlIIuYRikPLht+vwm1kZHlpjMMzwjm2fhBuXE=";
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
