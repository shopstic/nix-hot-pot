{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.41.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-cUeM40y8tX7SpXolLZK/k1ejaIzJu3/Ji+Rev33S4cs=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-3VvYZMr3rhJPZSVfYH9NQTHfHTOMU4kfqdBY8MlECfQ=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-iAZIczg+D1PB+UxGEuC5FY3qbLWQoeVxUxPYLxdQ47E=";
    };
  };
  priority = 10;
})
