{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-uS/ZiF6dt8ToCtQEv79o0MNhYZxj0wGuI6HkrxBVkvo=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-DbiiJLz9ys2QTj6OhUvf5mp4GSP+1Eyl7FxQl7y/oKc=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-u2Yrn71vmhP/uwyXPjmkZw20i6V78ynXnABRrsQn8ko=";
    };
  };
  priority = 10;
})
