{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.3.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-jtQlEJ6NWqq7lMKB8eEc0sE+i73sETugqWBtPcvf7is=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-icyI5bftvShO2qabQYB2GtwB64pq83pAgkwq5KL8ysw=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-5tprGbwU3y3EwUdV9P5Nnm7UZklaBMrDeHt5j5T3yP0=";
    };
  };
  priority = 10;
})
