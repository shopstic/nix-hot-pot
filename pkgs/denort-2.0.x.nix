{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.0.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-4No2IzsfPDBH1Sm41zXE/EYyEa3H0qQdaKtNa5Jgrsc=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-SfsiMh1PkjEkzgmnw8nCRtFMV3FEXjCoL1orE5CR08M=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-bzkYtSf923uJumEEu0iSD1zIHBiV5Xjm4ODKaRmGw6w=";
    };
  };
  priority = 10;
})
