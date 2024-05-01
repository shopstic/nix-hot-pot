{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.43.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-5Ja6M83sFig/IsGIMxIkV/LL04CQRfuAHAoHESP3/4M=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-jLbkLfNMjmLcVKtHqTbvs7BhR1anav++Q/4H0ijn2t8=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-Huj2TUvEqSOUlp1lKBrS4yGHqbEk64/WFzXLVtuc82A=";
    };
  };
  priority = 10;
})
