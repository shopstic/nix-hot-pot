{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.42.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-ugmddYWmNZLfUcCd0J1k6u+pxmpV7Pb067fdOBi1t1A=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-CELSemUn/12CbdTL/YjTX0h1qRIPB+alB0xCD8yQFzE=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-eMASSLJyeTNaCJpgdWTWL/D8TxIZqUsatfQJZkTdgKw=";
    };
  };
  priority = 10;
})
