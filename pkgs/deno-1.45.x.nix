{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-2SC+rVR99Rwr8AsXHSJXpdzN4UFHhPRTjNAVRNtw6ts=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-vrM3utUKF9DnIVa4FZX6cWAKNz6KIM2DbDYvKWBlQbI=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-8naRPXtJ0CLVuvML2rLKYlJSE8r5xLCvjUytB0T2ROU=";
    };
  };
  priority = 10;
})
