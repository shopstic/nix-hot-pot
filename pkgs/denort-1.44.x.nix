{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.44.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-6YCqEPo5SPJscFZnWRpaZpLLjShkM9sndJB8C+Yxg4U=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-HqUAIBPPiVFzff5CyEYItJPAlXT+SXWIcqBrYy03fow=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-VPZL15jSjb+YbVcrGskUaODd9aum0pwOnV2DUNrKjns=";
    };
  };
  priority = 10;
})
