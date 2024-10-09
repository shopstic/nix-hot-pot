{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.0.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-HRUVuh+HxtubA8m1x8LuoCXIT3FQu4ZGaLwTVEA0LWw=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-kox0t9YlXjwkvg9wo/+/Y6ilQdIb724RSWDl4O9tO94=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-ua0rjXVD3Xn2ZbuCemk3DLcPqBW0V4NVz4Gh5XPuF2k=";
    };
  };
  priority = 10;
})
