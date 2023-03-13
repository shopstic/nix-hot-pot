{ autoPatchelfHook, fetchzip, stdenv, lib }:
let
  version = "23.1.1";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-XLCIHb5l3XEHDCwWKiMnXPKz1R2XYkJYD2XD/jI3zec=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-NnMb3ZRZ91/6wEDxnGxQJNfHJxIfgtIEiDN2u7Oi3X8=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-NnMb3ZRZ91/6wEDxnGxQJNfHJxIfgtIEiDN2u7Oi3X8=";
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
  };

  nativeBuildInputs = lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D ${src}/rpk $out/bin/rpk
  '';

  meta = with lib; {
    homepage = https://github.com/redpanda-data/redpanda;
    platforms = builtins.attrNames downloadMap;
    license = licenses.bsl11;
  };
}
