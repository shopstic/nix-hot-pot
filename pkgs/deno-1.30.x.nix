{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.30.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-6BXLr4bdysOhDc2zoem4zyaTXh3WSpantQUiGBHz51A=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-GiuCiEx1ZN/H9KUyjjwSXwTwuZir/DgZ+qalXBF55e8=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-0ttNTMUvn5OIWAGpe0S1mWefsAh6MlaIZZHu04Msncc=";
    };
  };
  priority = 10;
})
