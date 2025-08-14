{ autoPatchelfHook, fetchurl, stdenv, lib, makeWrapper }:
let
  version = "0.36.0";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-2IquGGpV5Yk8MY87Ecg4ozcq302sHi/TvH0rVZRMV5c=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-mP7mg4RyqdL5D5FFNEna6aWs/cEsNq/vrmdiX78/EP0=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-u4oioIzNmmy5PwoWIFt7vrBn3X/sH2AifGh9jek9YIg=";
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

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  dontUnpack = true;

  installPhase = ''
    install -m755 -D ${src} "$out"/bin/atlas
    wrapProgram "$out"/bin/atlas --set ATLAS_NO_ANON_TELEMETRY true
  '';

  meta = {
    homepage = "https://github.com/ariga/atlas";
    platforms = builtins.attrNames downloadMap;
    license = "https://ariga.io/legal/atlas/eula";
  };
}
