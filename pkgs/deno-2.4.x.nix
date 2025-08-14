{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.4.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-ymG+XiPUyY/zc0EQAlXS4pTL+Ol0Bd0B8wOeYi2UE/k=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-fuufGdtnJ9Q/lk3xVmUdeB5B1BW+11PEWc/2ddRRDT8=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-ArV/hc9y1AwEQ1yad8vBR4wV+zVlFugI2pw1pFiHGe8=";
    };
  };
  priority = 10;
})
