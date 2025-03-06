{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.2.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-7reSKyqBLw47HLK5AdgqL1+qW+yRP98xljtcnp69sw4=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-bIFNcuEgRESRMoUCt0hQt/rdVLV6v0vIH4TJOpae/aU=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-ldD6EmaCM8O6bMdfFBW9bKbm7WK6GocHqld+LSeVguI=";
    };
  };
  priority = 10;
})
