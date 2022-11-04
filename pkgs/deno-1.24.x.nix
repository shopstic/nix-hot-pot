{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.24.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-CvUUsM+1J85lXV2yZeNW40uvXJttmYp4k6Ah/q17Foc=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-UYNl8YQ5o/PiTBu9h46+L70VmPzp4FrAC4jfZ20NnSs=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-f9u9uPL5fPzLxb6tnBnqRibV7Ia/yglMPy92uAk+V1c=";
    };
  };
  priority = 10;
})
