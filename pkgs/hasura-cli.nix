{ fetchurl, stdenv, makeWrapper }:
let
  version = "2.35.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-amd64";
      hash = "sha256-vXqAqAO6p5BHubz/oeRppINIyUg5D5el7kBAZD1BCZQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-darwin-arm64";
      hash = "sha256-G6jPu97yc8cTKAhsZT68XWGd+9DM95lMKwNKwxBlrk4=";
    };
    aarch64-linux = {
      url = "https://github.com/hasura/graphql-engine/releases/download/v${version}/cli-hasura-linux-arm64";
      hash = "sha256-TMDZbAru2tszl5KaFhvm/40lA0rS8joLyTa15IOHnvE=";
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
