{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "36.0";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-RCmJx8Y196kDluBqehE54otbZJzJyCtE/t4Ujx/yJcE=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-mdHQXdzqt7V4isfgwwV56vlP98VmXywRlkZnfvFBpUU=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-71dB+0ugkKQUBAfNHVy9QaUnsWeNPgvEtc4EUUT6I8I=";
    };
  };
  download = downloadMap."${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "mizu";

  src = fetchurl {
    url = "https://github.com/up9inc/mizu/releases/download/${version}/mizu_${download.os}_${download.arch}";
    sha256 = download.hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D ${src} $out/bin/mizu
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/up9inc/mizu/;
    platforms = builtins.attrNames downloadMap;
  };
}
