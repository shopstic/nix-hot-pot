{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.3.6";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-FeCxj/EIznLBKD+Do5u68kqEoG1Fs/n22GBm/BHB4xo=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-/MDQ/pdcnE/p8zpdk6LO+FqxnkimTDtGsUAp7u9fJq0=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-pfk13sctsWSWk3Ia7icQEpuYqaHXegL+gN3aupTV/aw=";
    };
  };
  priority = 10;
})
