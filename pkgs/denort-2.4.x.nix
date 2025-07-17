{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.4.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-ukIk8K2CE+N+3eFs++RPiGZlhhRRVk1gjhdt77/s+4o=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-7e/r0fUJNl63esmZ7ZhLU2v2pqXZjMuHheoGFjskRKA=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-1RwjT+IJMYQ1rkCzkEv0r7hwPOK/T4ouqSN9E8AGEBs=";
    };
  };
  priority = 10;
})
