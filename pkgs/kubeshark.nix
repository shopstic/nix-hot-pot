{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "52.3.96";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-p1MGw7zlBpDEDeILjUpSuFurQ5aNSaAH1ph4s15vFJI=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-w3HpN/TnvRU83EaKDdT36N18HcWtD24UapAgqeH5lN8=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-qmM+/AG5I81tL0GRrFxVqBrXYS7Fl4jhWMw9+dMNegg=";
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
