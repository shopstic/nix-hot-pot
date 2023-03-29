{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "39.4";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-QLbPc3Mtb8cqSk4lUfcpyTBcsTQUQznd8Qn5fcDlbEI=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-09UartWLhjFKds9M3tR8g8eqB0wPXLS0KBh+dXNUr/U=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-zvvSOw6bkhj+oXQrRR+9TJhbvG+Suhes16JGPburSiU=";
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
