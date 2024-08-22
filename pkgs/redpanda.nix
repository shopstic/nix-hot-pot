{ autoPatchelfHook, fetchzip, stdenv, lib }:
let
  version = "24.1.15";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-mOsAbKnx59apDPpFwqmkiN30oziGIcep1C1tpRkiXfg=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-CZBWtFc0lHth4QKoiP1NTRtqtfmQxk6y8B+j6vuc8mQ=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-7x4pzlVTytJmx+2MWRajJ/bWGtz3T5nPZjgkVQ0cZz0=";
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
    stripRoot = false;
  };

  nativeBuildInputs = lib.optionals (stdenv.isLinux) [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D ${src}/rpk $out/bin/rpk
  '';

  meta = with lib; {
    homepage = "https://github.com/redpanda-data/redpanda";
    platforms = builtins.attrNames downloadMap;
    license = licenses.bsl11;
  };
}
