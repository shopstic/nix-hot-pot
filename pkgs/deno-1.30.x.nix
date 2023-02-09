{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.30.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-fXY/TenGzUXxkFiODGlMxJEGOQPrdg72AK6dRVGm2z8=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-6lzTrdYwypusz4mg5O/CghaU94DuE/kA6Ee9X+d9G5w=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-uIaNwdpoBQlI9AhLmgG3Vxf8Y0AArF2q1UI23fSJBx4=";
    };
  };
  priority = 10;
})
