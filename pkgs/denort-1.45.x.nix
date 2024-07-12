{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-zHixjqb/s7cQcZ0Prf8lBkDXhVuf486OeX85dESgOF4=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-A1HoeQr3bxTprOU1kxbqFS1SvgmM2bUiaKqf1vMNgM0=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-AcZfyGdXWpULNnyqzeGOIvLGBAZaM+l3i8UXJILXMR0=";
    };
  };
  priority = 10;
})
