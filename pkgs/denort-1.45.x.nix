{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-uhSIgqceBjnCzM0dqJx0O1Y1UBdV0Uv5x2NI0cCwq5o=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-Pj0pQTQ3niG2r9/pDMZ3Csm8PqodioZv0QWEJlzKeAE=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-k0SSCy/QKLtuxVqVJlDseocYful5oB7eHHmyrox7s/Q=";
    };
  };
  priority = 10;
})
