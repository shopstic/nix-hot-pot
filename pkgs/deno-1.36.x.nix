{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.36.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-d/ajDdFdZV2eJAkIYQl0gkJWPPP0XYP2Vo9IPYOd3hE=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-gufiiBMf06v4bWteZla1vkhvSq6134wxBcEYov27ubY=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-E4+y2XZGbWJneH2+4ECqUAC1hq3ICaN0Kgo5pmwed2k=";
    };
  };
  priority = 10;
})
