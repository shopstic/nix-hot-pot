{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "52.3.78";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-W8TBE4Hc5jfH2LtCj34Cn7Butnsed33nNm/HoBNEWcs=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-+zgz6A+qoAXzVkrKe73Fcv5JAq3vZ0rBXd/2+0qWPmQ=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-9V4Jeg0MkwnhVbEB9FSU6iNcS69H7NLEmE3fWyqS1Q0=";
    };
  };
  download = downloadMap."${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "kubeshark";

  src = fetchurl {
    url = "https://github.com/kubeshark/kubeshark/releases/download/v${version}/kubeshark_${download.os}_${download.arch}";
    sha256 = download.hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D ${src} $out/bin/${pname}
  '';

  meta = {
    homepage = "https://github.com/kubeshark/kubeshark";
    platforms = builtins.attrNames downloadMap;
  };
}
