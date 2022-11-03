{ autoPatchelfHook, fetchzip, stdenv, lib }:
let
  version = "22.2.7";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-hUChGYimCFXEvSxb49QgPo/LYlef0ZMVhKNy9i3SpVA=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-z3BiFeuJv1UO6hfHCnjTM+6ahkPYOeb4Di+qOVgQkhE=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-DqcS527OayidVGScObUysAb9pAaQyGNrZAUxYspzZ4Q=";
    };
  };
  download = downloadMap."${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "redpanda";

  src = fetchzip {
    url = "https://github.com/redpanda-data/redpanda/releases/download/v${version}/rpk-${download.os}-${download.arch}.zip";
    sha256 = download.hash;
  };

  nativeBuildInputs = lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D ${src}/rpk $out/bin/rpk
  '';

  meta = with lib; {
    homepage = https://github.com/redpanda-data/redpanda;
    platforms = builtins.attrNames downloadMap;
    license = licenses.bsl11;
  };
}
