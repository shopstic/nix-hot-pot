{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "52.2.1";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-Hd91UAofUyRpC29fwzHQR6IGrm7FkfsZ06+fn+IE0Bc=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-V5Wnuhs4ZLxqK4CQwtYHtuMUaSIDO17vXUD5gijwIQ4=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-lcCaS4x7a8joCAeKyH2+NhCsfTQAY2co430140f6/FA=";
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
