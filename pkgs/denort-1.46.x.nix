{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.46.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-BGs0eQ4JD4kX5Vilm9wNKqIBneAReiwtMF149B2aeMA=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-N9lb/ZsTkDz/GS4eaprUQbjvxwUP2+Kpt766oWZp2hg=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-Gz1RXrsiWIjQya9TsVWaoSw9QZeqlpd5KkEtkAt9Ygo=";
    };
  };
  priority = 10;
})
