{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.42.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-i/y5T8y4RABYb2b7qAF2eP70tSPeBGtRQVL/zuY2+Ik=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-4XjtoLz8yiYYvBEDkWeJpKdUQfdzSiRgcPyL2snS4us=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-fROYeEbzVuMwqEVrA/4x/GzhZJ/EUc8SXPCzI1kYzp0=";
    };
  };
  priority = 10;
})
