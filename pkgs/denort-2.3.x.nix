{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.3.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-OpAz9gdtDZZfU0mFpgmaxRz+8S8V+xMHkevpfDmZS6E=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-vOIQMveSXBxoylRiJoGK/pzqTEQTWHo8Uhky3NtJpgE=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-DIdzCdIpxnWt4tOdvT/UNIxHlOBcCaUMvqqvC2jLb+I=";
    };
  };
  priority = 10;
})
