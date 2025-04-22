{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.2.11";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-QLowPPH1OTDv23EOJVf8mu7k/Vk4mhEl1r7kivs9O88=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-07PI1G7UPyQIXMV5ZbvzxgR6KSpG8oA9aWoG3BWqSxQ=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-0tpvcQtgWyVqAUVRHZ3L9aNceiAF+kVylsy34WbZS+s=";
    };
  };
  priority = 10;
})
