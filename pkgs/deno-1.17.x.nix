{ autoPatchelfHook, fetchzip, stdenv, lib }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib;
  version = "1.17.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-Q6PsFqVRaaLUaMENqNBh8gxYcmT5yDX3kbvGlZkHsj4=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-3yujeKgoRGg5tTd/+TcofrWuPvU5sLzR7aGsAo9BbIw=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-DKApsQWmhod2D2GQ9C/hTCBgv2NKtJ9+WzF9+rejzXk=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-S0WYIQa/ifVvPdKgwmuT3RZh72QF0cMZhjzls+4I9kc=";
    };
  };
  priority = 10;
})
