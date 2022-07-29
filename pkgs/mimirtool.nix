{ autoPatchelfHook, fetchurl, stdenv, lib }:
let
  version = "2.2.0";
  downloadMap = {
    x86_64-linux = {
      arch = "linux-amd64";
      hash = "sha256-HTEfal3eOOEfqnzvw7Ij2yOyvjKrqt7pjiE3MfWcook=";
    };
    aarch64-darwin = {
      arch = "darwin-arm64";
      hash = "sha256-F15k+y4qLNsWvsJi1A7Mr4Vflw8disYUWU4q6DZUojg=";
    };
    aarch64-linux = {
      arch = "linux-arm64";
      hash = "sha256-ggydZWhbY7vdrXDFEWYhV+x2WOfv9pph59TPS8vtPJU=";
    };
  };
  download = downloadMap."${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "mimirtool";

  src = fetchurl {
    url = "https://github.com/grafana/mimir/releases/download/mimir-${version}/mimirtool-${download.arch}";
    sha256 = download.hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D ${src} $out/bin/mimirtool
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/grafana/mimir;
    platforms = builtins.attrNames downloadMap;
  };
}
