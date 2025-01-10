{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.1.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-7z3e6738K/1bDj7GdvHvW9yijkR1A4EyTEyNYvfdUas=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-+euBxn2J4C7EQf/QNB2H3GJiByUnbA4mOV1LmgrN/zs=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-R9eH8wwOD4E3y7JJ5QxyYKRxn4Q/62mFcUiLRmnv+zs=";
    };
  };
  priority = 10;
})
