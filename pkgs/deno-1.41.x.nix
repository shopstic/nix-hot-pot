{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.41.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-zkU94b0owyJvMkO8E2khNxFPJrDzBsfXncL0UOj6W4o=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-nIvrhzgislO194hMDsPYjdBZTnwINUxDpeBSb3iDtAM=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-84jSBvDql2WvaJvaPNZVFvRtANVk+2VU9Q/DSatGN+0=";
    };
  };
  priority = 10;
})
