{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.46.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-GaWw5AG4ptM0kswkwCVifNN5UUnYiuYuDYG+LMs7xj8=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-rhyULc1zNiiw5Xag/apr0CsgIvDLOGbGCGb/obNsFxM=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-vw6AFXdZ/dP/DplWGqYiOq52O46D7B/p95AopuyjLqk=";
    };
  };
  priority = 10;
})
