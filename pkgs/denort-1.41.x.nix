{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.41.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-cR3e48k59xcHCOBhbERLCVgvnk2TBRjN7NQ23OszxaE=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-bXoiDswIx0FNMwR7q9pXcmJG9yMbqy6h0iNQOINxpto=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-GJjoBMqOo0hud+0ZuW/xCne1/xh2UmeQJO4RF3T+bH0=";
    };
  };
  priority = 10;
})
