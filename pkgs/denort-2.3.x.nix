{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.3.6";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-tVfladvRfFB0oH2gMpOuQm9BcTRfyIPlDtptvWxsyKU=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-g8KgTs9jFY1xvIJqu+jg1HTkLjnQHRKqGXfeOR/oWpw=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-E69E8qQh1Vu+YXtQ2/soZGpuc9D8PmVSmXZgz7SB0CA=";
    };
  };
  priority = 10;
})
