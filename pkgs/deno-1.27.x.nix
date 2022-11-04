{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.27.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-QLFvrPdAECfEsvew+5Qq5IGe+i4I8st0Cy6tymlkRrQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-KthA1n3Hsha9sLMBINDMrUHhdO7Cigxn+rDI0iYY2WY=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-kh6LZUm/s5puV1WOphV57uqLZQdR0mMcKvsE6sB0oKE=";
    };
  };
  priority = 10;
})
