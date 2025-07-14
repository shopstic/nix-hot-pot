{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.4.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-9Y60RnyjaqQI13Jj13+Q+NzmyN4u/eL6ZkkNs+LMJlU=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-QnI+RomhMEhnNyOW1ZXFtxGhTnokxHoaPX+W2R7JNkY=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-qpBuEed7Ag9AIdq8HcnMzKSivxdRACWgDz1mSs8o/dQ=";
    };
  };
  priority = 10;
})
