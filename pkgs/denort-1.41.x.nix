{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.41.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-5ltu2pbpXOZOYPvEu5vKnsPRoOXHn6AeaYjTxVBXc8s=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-ycDyTAUDRpvgm6FK6Kbo2Z1p9py/u48p53gU1aEeo/I=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-JCe7OsLTI4pA3a7uYyeLhBzATjW7pBJC/8CfsXDJag8=";
    };
  };
  priority = 10;
})
