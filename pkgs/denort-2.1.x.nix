{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.1.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-5WPmhpjnuP290bbj4I/UCsfZFzGEk+L5dRUKNnSbp8I=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-23hLT0u3E5B2DqiNNbNpxzoB3XetCnPLbOOXzKnpqGE=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-0w2gbBF+aGqkbAeKUwImnlShZBFMvZ06/p/SV1CChQE=";
    };
  };
  priority = 10;
})
