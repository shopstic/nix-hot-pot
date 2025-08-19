{ autoPatchelfHook, fetchzip, stdenv, lib }:
let
  version = "25.2.1";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-jutJ/Mb3KjKSWhZ2dMTqj/KTWyW0bAYZt1vQWSkh/To=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-eop0/gRh++86fIuzFPzwnv6T/TCwLXXr/0lqPg+EX+8=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-hfILa3KMB+Lg2fuBl/uTq2YxKf0EdaO8S+vJY=";
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
