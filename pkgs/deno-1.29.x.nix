{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.29.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-ldSmovX5+VSQGz2O3aaPg9ek5irkJkXDyLG/SQR2o+I=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-UUhFJNiz+XZNB3EIIGeYU3xeRSKI3fpe+kZ0V3zdids=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-UUhFJNiz+XZNB3EIIGeYU3xeRSKI3fpe+kZ0V3zdids=";
    };
  };
  priority = 10;
})
