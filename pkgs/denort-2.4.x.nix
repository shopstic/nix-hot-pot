{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.4.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-dLtIr/iQ0pUYViJiIQTp/0nYX0MtFxcJMiKF18XFH4E=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-9y17dlU7A/ESHtOiBQPbCi4ayWNXjymUg2+LK0gE8rE=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-WsOk/rZXL30C8Oko6btWFFj78ncgF0EsP/gs8xxPzdg=";
    };
  };
  priority = 10;
})
