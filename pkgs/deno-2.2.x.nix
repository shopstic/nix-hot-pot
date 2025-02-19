{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.2.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-bk6HnmLC6R/p8K5UP/bTIsvvpIXy7hQiFdrCwoEUPCs=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-lZVZ7fQ1cOaSBvPP2tGDmfYuT0DY7M+ffHJQEzNQOOU=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-onwasod4Bm5AUYnA06L+/opzoKnJh2njqlwlVJRh6hk=";
    };
  };
  priority = 10;
})
