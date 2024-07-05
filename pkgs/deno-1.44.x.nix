{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.44.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-ucPQnex8p8dzytIXBTVRuXmmUs9tvHOC8DhT5EfzrlA=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-qjRtQSjjYaOI+e60CXkg4yj+jrXJ16XSXQSjVOdZeRY=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-oVXsqKKdainPNAlA/oqj2wDaKks9HsQgHfIIGXygTQI=";
    };
  };
  priority = 10;
})
