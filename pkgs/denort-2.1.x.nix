{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.1.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-Kd2HgwRVtkcl/V+T5wfBGnW0bQqJkCaPJdcHaYTdx+s=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-VkF2BYZg/QPDoQ8EUS0OBPzLn1VoMPQDuv4zAwwqTQc=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-RRUTFbwtDZgQD6KuiE2SzEyi3nrtLbtJzKZOKWyp5vs=";
    };
  };
  priority = 10;
})
