{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.0.6";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-roQ/SHySI2A+9b8WHcyyf8SFteAiuwMmCHQc0xivYYw=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-ULy61H3JP8W+11kX5nBi3idi+2NFRhD5/TOOkgvqtPs=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-QtvqoXnyAsQ64T6QhPIzXydFPmTOaWKZa1Fry4NB0zs=";
    };
  };
  priority = 10;
})
