{ autoPatchelfHook, fetchurl, stdenv, lib, makeWrapper }:
let
  version = "0.32.0";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-gWCjVxYBQiObhLjr33D3r3DfjM7+KXKZ9DzGdHBTIAQ=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-qPswIx2A4pYrEh3LsHP/8GOiEEsRu2wdD2dHfbO3KMg=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-Fe2nWAhLUjWKR3v3+LgJPvgR7G4x9jUJXQxBqOvmqlI=";
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
