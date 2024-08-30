{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.46.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-eNVFccVpkft4PpMOVNww+J6L6j5LZKtZ/HJ/QabaSlU=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-NLp0WV8n0reAmrVokjMj4EZSrafwWI2NfQD1quk74+0=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-m+b83g6K4OlGvrKTL7K8FHILwhoC3fiflhGF5FfbNeI=";
    };
  };
  priority = 10;
})
