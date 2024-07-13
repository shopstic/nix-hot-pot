{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-1DVm8TGFUeQajFwqRX2ZaDKB/SkXzTsRzURsYHfoShI=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-6dg+sdjX/P48+jFMIvnRlQUl61osMH2geY11UJEXsh4=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-OdtRuqPU1O4CRxvPX5uB5On9DcjlbDCZIFlg8P3olvI=";
    };
  };
  priority = 10;
})
