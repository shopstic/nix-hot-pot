{ autoPatchelfHook, fetchzip, stdenv, lib }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib;
  version = "1.26.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-FZTFNXXDBR/Oa2c6hpcR7qkp043QXwwqo5yFVxIR3Tw=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-Al8+PZ7vzMP8yO4JUcF/bThNDW3na8/O+u5sXMt4cic=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-MOIJSpntmfSxPDtiDZp6CXo4d1KLAnnaU6171ps+HOI=";
    };
  };
  priority = 10;
})
