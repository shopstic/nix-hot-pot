{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "52.8.1";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-3+aqrcVOfyMK7BlzJdCyRORXS1KqVt8qHVxJkxKb9E4=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-sdwVpfMybvaWk/Ab68Q2w8cxWx52Nj9ZczHmxdTtEMo=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-9PXOfCi6+TwXr/bXKjWBE2TuwozgkRVOM8/1E=";
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
