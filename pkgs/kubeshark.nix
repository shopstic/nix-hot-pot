{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "41.3";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-n5O903ecjICeVhT4WcP348EiEBMi9QO0VVF2KQV5ZSY=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-ejZhRxmjZhEPMjD657KStZptVAMjixsvdusNxpX1LZg=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-4VR7aAcWA7bzCPLdUJhiTiKDpAVNR0hBt3zy2cv/A+8=";
    };
  };
  download = downloadMap."${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "kubeshark";

  src = fetchurl {
    url = "https://github.com/kubeshark/kubeshark/releases/download/${version}/kubeshark_${download.os}_${download.arch}";
    sha256 = download.hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D ${src} $out/bin/${pname}
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/kubeshark/kubeshark;
    platforms = builtins.attrNames downloadMap;
  };
}
