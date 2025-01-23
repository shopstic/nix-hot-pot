{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "0.30.0";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-gHiHN2OJY2+QjZdO5tcjUsEJe3NPbiYAFpdqJrnWlL8=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-yLDu2M2oXSX9NbAivn8J/BGNbOeQ8wRZqtK4Ql1Ed8E=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-1zgNXkcVh4xEEIq+ahORvDhzUxkpnwrzZYvVp4qgOxA=";
    };
  };
  download = downloadMap."${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "atlas";

  src = fetchurl {
    url = "https://release.ariga.io/atlas/atlas-${download.os}-${download.arch}-v${version}";
    sha256 = download.hash;
  };

  nativeBuildInputs = lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  dontUnpack = true;

  installPhase = ''
    install -m755 -D ${src} $out/bin/atlas
  '';

  meta = {
    homepage = "https://github.com/ariga/atlas";
    platforms = builtins.attrNames downloadMap;
    license = "https://ariga.io/legal/atlas/eula";
  };
}
