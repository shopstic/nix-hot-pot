{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.43.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-KTZUdvwgtTqAwMTeupfEy4QR36nbk8CgoWunDh5Sk9k=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-uBMUOAd5SqbAXYBqT8dwkSRyhEVnLzvIFlk0BZuBhHQ=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-jHnabX9Q7UJUSCot3f8PO9LSctrc04fX72bIgyaOE1Y=";
    };
  };
  priority = 10;
})
