{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.1.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-Ccx6KxNJ3Ssy9fQeN5wu5amlg5WbutW1RJtCEZB6p/s=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-Exa2yrO/EKtK1Jpo6M5z4HK+B7f0ZVGsuRB6TtkY3zE=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-uCrpsqdr8DxdnHAiIXN2cxc+AkuIy4goDajfN725krU=";
    };
  };
  priority = 10;
})
