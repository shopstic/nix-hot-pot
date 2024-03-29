{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "41.6";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-EwpX3/ESDMd3jFYpU6pJME1Woz2CUgBzna8quRhy3J8=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-L+N5+RkDoNknklA3yfsCVevAnpWTx0iJ5r02aRmw9Qg=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-guEPU+6jtm7DmqMMPzkAFih3V1yj+Snw3ltIweP/qj0=";
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
