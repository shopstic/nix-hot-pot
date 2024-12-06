{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.1.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-BQ1qc9qM9qVGRwa2D2WUOYr1YcAcBZqeL4u/2sErqQM=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-A2NRpZ9w6XS44xD1LvklzQtTsWB4B7cZlt2CA/hOl9U=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-ze+S9llqWbLImgullTTaAVU/pV9wuXeBEKNAgCE6jWI=";
    };
  };
  priority = 10;
})
