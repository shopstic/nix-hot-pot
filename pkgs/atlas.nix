{ autoPatchelfHook, fetchurl, stdenv, lib, makeWrapper }:
let
  version = "0.31.0";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-+CG71Gbtd/aYFLP1Yn/+VFikOs0owFw/J7tPMmfdBCo=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-aSA4KLVZlsBnhNRu8XNxMkiaF5T7RZuipmOlH1p0DKo=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-sQwCsGEHIP9PYBt3qMH1Uh6J9aFKbn4Mx4h/skTgRz0=";
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
