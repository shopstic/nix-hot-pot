{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.1.7";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-oA5eyYcJPXfoUGfs+ISLwB2Qjk6WhVAFlAM8ZAVrI1g=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-k9Fy5UUhCzX4W7rw9iCd6vhmFSyfzya1irAC6yPoq2o=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-zdXtQ5o4E3T9M2IpwDQDDpnpXvMVR4z1W5hohY46LaQ=";
    };
  };
  priority = 10;
})
