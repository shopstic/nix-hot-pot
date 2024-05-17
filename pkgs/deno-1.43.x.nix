{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.43.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-6iTMhOiKOAwLnqRlU8cIGYYkG3LWAEsL45mVD2mzL5w=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-wddnEW5XD3IEiDrSr9DSb+2NzB8LS2m8fVDmX1lx1o0=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-qQyDpIzwjRgWgLtlMR0HolmhlNd0tZaI/PaDHCiAIrs=";
    };
  };
  priority = 10;
})
