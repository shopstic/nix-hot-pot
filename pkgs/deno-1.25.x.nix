{ autoPatchelfHook, fetchzip, stdenv, lib }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib;
  version = "1.25.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-I7E1MmK8ajTsshhDDnxpSh3el7ux9Q/0tCRCLCVuzek=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-76UhWIelbVUwSjkRvfKgKs7t/XjkI1s9FV6A7El2wXU=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-PYDV0FDSwN2Ok78cb7ANpWu+IrjF4Rf3A/7QVhEcIuA=";
    };
  };
  priority = 10;
})
