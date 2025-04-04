{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.2.7";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-iDBvTCLmCdVtxv3shRVd87PLYmZkDbKqQ2VBSPFZ1m8=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-LPyn3e8mkxStVHIjyEQI6dyo7vzmPhFr8C+0AZo4ke4=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-NyQdw5FCtyD5nKSKEsIF9ZCZeY8B+ZkeSWRN6yuZbOY=";
    };
  };
  priority = 10;
})
