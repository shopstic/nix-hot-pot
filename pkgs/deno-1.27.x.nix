{ autoPatchelfHook, fetchzip, stdenv, lib }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib;
  version = "1.27.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-Bh2ecpp/YZCerWoxo2p1ojHHMJttz7dNdqUpomG9/ps=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-bcZdri0oL/WfJFYaAsUjaMSfShZeJ678uW0Mz3GwRc8=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-s+BfG/g5mBljCBrw99JT3lTLv7xO8+W24hzceCHkcrU=";
    };
  };
  priority = 10;
})
