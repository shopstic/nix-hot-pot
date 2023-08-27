{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.36.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-1xNjbtO/Vgfw1deK7f3lprYdY4Bzp5bPemy0dLgodvU=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-lCGYGt/lwSBaPHYlhbsymOG3VAV7HXnfU7D+PeMbYck=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-qOuvEj94O0ksvnpqeAvucXPeASbw1aAMui0aFwZjdV8=";
    };
  };
  priority = 10;
})
