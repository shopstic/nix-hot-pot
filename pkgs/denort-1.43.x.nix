{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.43.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-1jqrEmBQGgQdJE8D7cLE5slXAwWJyD4dWfIAC8ZfpR4=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-SWJAnLRkUHHjWK3GBN2HOZ+WKSz1oj/CiPQ+I7QopMY=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-yDj9R9WSPig8nZSud/pMwvyIENjutYmmdSX02RjWK3o=";
    };
  };
  priority = 10;
})
