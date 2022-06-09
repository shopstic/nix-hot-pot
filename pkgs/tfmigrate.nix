{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "0.3.3";
  downloadMap = {
    x86_64-darwin = {
      arch = "darwin_amd64";
      hash = "sha256-Zlh07zgTYdPrwxcozSeWgYlJYDycUL6w1jQey+CC55E=";
    };
    x86_64-linux = {
      arch = "linux_amd64";
      hash = "sha256-n+3fRhfzFs5DpKyWMOFXwTTc7OP7zRN1tSPGd/uCVbc=";
    };
    aarch64-darwin = {
      arch = "darwin_arm64";
      hash = "sha256-/3XCJY9Mj6l07H9zCSSHQHTr8yevahtME7pTy8XbSi8=";
    };
    aarch64-linux = {
      arch = "linux_arm64";
      hash = "sha256-sW+u8PksPoLfMEpCMYdOorSw+v0ocqlwmzzONoaUNOg=";
    };
  };
  download = downloadMap."${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  inherit version;
  pname = "tfmigrate";

  src = fetchurl {
    url = "https://github.com/minamijoyo/tfmigrate/releases/download/v${version}/tfmigrate_${version}_${download.arch}.tar.gz";
    sha256 = download.hash;
  };

  setSourceRoot = "sourceRoot=`pwd`";

  nativeBuildInputs = lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D tfmigrate $out/bin/tfmigrate
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/minamijoyo/tfmigrate;
    description = "A Terraform state migration tool for GitOps";
    platforms = builtins.attrNames downloadMap;
  };
}
