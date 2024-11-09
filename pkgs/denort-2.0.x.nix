{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.0.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-3d8sWmMb6E/KagpRmJG12SH/uwqmHJS8dMyjVgoJYL0=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-GuE3bfcZqx+E2p5nKshQQvKR24MCUNASYAI/6RUIawg=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-vzYfySlQCJ2fNF0UvElI/ygekoNXtO4T7PBgDwl2uDQ=";
    };
  };
  priority = 10;
})
