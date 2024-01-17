{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.38.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-AjOVIMaikt5jWv9dIaNZhHLpgtfG+NPeDtDhsqQ7EZg=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-JwnlseLWb/iK2cKTs7Dl5K62M2fo7mhba2KwdfGZjeM=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-SLjo46Oejx+/phrRdJzhbPogU3C+Rualp/zmm0M1odM=";
    };
  };
  priority = 10;
})
