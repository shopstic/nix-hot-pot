{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.2.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-KUXtEwN82J3lCUhgieIkx1ce+4gg1H16WZaZLC/I630=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-WWChV5OyKf4ufJAsm2+NfuS/0Kbylg4kqkUwF8wsrOw=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-9AjLKjI3RNKR10H2S26SyYboE56Cr36cjNeWoKmrI8Y=";
    };
  };
  priority = 10;
})
