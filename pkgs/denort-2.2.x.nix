{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.2.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-8y3cmbV3o2WKPTwDNFp6F4X4lBWnlJXTPcC+t5+I70s=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-mfmczPiQuRRP5OFX65uYhhQZu32O9CDIcIR36jsGRaQ=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-OpnjpSM9BWwWWAGZOgcqqB5kVGMoRfCaUG/FzJ/8V6M=";
    };
  };
  priority = 10;
})
