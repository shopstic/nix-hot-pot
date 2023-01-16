{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.29.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-9qB8G1nldjaATGYwDuKKLeS2YMa8T/H97dQBwf5v0fI=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-RISluvDeo7h08NNdAWMmOhqxF5pK7vo5vJ4lE/C5nX0=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-LytM7bia0sOqGs9B07CU+8I2Zoes9WekU3PxwoUgIWA=";
    };
  };
  priority = 10;
})
