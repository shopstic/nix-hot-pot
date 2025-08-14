{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.4.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-rsrpCUkJdLiwF5My6XIjh84ISsD8HAHGlvp3YM/bWYY=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-Uj3MJ2TCs+RuriikoE9BkrcHXWZC6xpHkWtHQT3C0lU=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-4RXMNossHzXE6ubDmhzdOpIe1pf0idc+l9yAxNRv+q4=";
    };
  };
  priority = 10;
})
