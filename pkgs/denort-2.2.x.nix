{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.2.9";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-XT5TSUapvvuGCCFd1NCwJYejF9Jndor07JCW4ccU0Uo=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-tvvpyuQQ9R61tYu3jawcTluFikZpgoTvR0S1Wh77hI0=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-ZLWP/0ssfWWUnleiguJIItiKpodlcf6h8rVovnOjWt4=";
    };
  };
  priority = 10;
})
