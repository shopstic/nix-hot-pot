{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.25.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-a4Sg4Kw1oyhWlVvEegaZTreksnznvHsputv+zN1LlxQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-m91e+ZqHoRJvcJDHni6rVLc8EwKwGTJC5MpBUlpmKv4=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-lFLOM99mx4kv9Yv5fUJRjSbYRbFesVidH0QYFgF2S5M=";
    };
  };
  priority = 10;
})
