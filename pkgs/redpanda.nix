{ autoPatchelfHook, fetchzip, stdenv, lib }:
let
  version = "23.1.13";
  downloadMap = {
    x86_64-linux = {
      os = "linux";
      arch = "amd64";
      hash = "sha256-u38IYC65SyjCulei18EBzCCDT3YdnvLQxmdGJ9JhoNQ=";
    };
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-2t3c1FlKFZgDPAHYOR55jKkTXuSBeJXzw1fxybAngH0=";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-VkvW6lD8rl+UneV/6ERjQoWN1gcfk1PqGTJNiwJ0Zqc=";
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
