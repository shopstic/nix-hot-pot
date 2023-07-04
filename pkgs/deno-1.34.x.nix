{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.34.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-Ff02L3kFmNzEGdUM/nD5H7l5jR1J4RUMRshpCHETK50=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-8BpCWPcur0Acx4QqstED4wPJxbVCrIiK4+vG2gwY9Fw=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-I7ONQu3w47YaTcv/sDdr8XIBo7FM+f3GbdjZZuQtx8g=";
    };
  };
  priority = 10;
})
