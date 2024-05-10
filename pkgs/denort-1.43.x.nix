{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.43.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-8dlXf2Gl2xlVTLRe1GwsB5JyTOGeA3v3cDxByeDcbdk=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-rYK9OxCc4qGq+F6E2mkoMcQoiuO3sgjVq29LbSU+VTo=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-A6kxWWrWRTSDwZXZf7RFKCg4svAz6C3JuehEcFzzPDM=";
    };
  };
  priority = 10;
})
