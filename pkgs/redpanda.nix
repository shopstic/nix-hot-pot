{ autoPatchelfHook, fetchzip, stdenv, lib }:
let
  version = "24.3.7";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-oZwKOdeKPGX+k6Yc8JvwkSuuLwnRV1lSnDiZkaxjRYU=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-N84qI3ezODHiRfOyh7Ngg7iwXoEANl1nsHvRS3MOs78=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-mMQfcNngU2yHDaqRWqjbv0Ii2BAFpw7nhXognsmzZEk=";
    };
  };
  download = downloadMap."${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "redpanda";

  src = fetchzip {
    url = "https://github.com/redpanda-data/redpanda/releases/download/v${version}/rpk-${download.os}-${download.arch}.zip";
    sha256 = download.hash;
    stripRoot = false;
  };

  nativeBuildInputs = lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D ${src}/rpk $out/bin/rpk
  '';

  meta = with lib; {
    homepage = "https://github.com/redpanda-data/redpanda";
    platforms = builtins.attrNames downloadMap;
    license = licenses.bsl11;
  };
}
