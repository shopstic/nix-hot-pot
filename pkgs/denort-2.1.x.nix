{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.1.10";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-2h24acFW805i7PDFIzCSdal+hg9AEfbf9T+Q2IHvfus=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-SbqcVbCJoD107Wq7DDZ22GT7oM5wZtg3pUakga9RzmU=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-pIDVkT/6lF5pbH0Vcg1Q3I/069GhmfaZKF3lQ5ZpWxA=";
    };
  };
  priority = 10;
})
