{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-gHhNMDk5rEVqeP13w3aYrZwNIJbQKZ5xMrPzObDwA/I=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-AW8jLL9xelC4IBuhvBK77gPUxd0a7cvXkAw3ooS2GzQ=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-B45iD77eWMtUZPwO13eNg8G4Ng+G+Z9NTrXDBT5gUwo=";
    };
  };
  priority = 10;
})
