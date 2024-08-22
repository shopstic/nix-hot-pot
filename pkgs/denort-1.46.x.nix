{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.46.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-2ptN+Z0d/fSX55nO2WAIJ3yoCSSxjSfNZpmie8ftS30=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-fUge8VDUvEs5ueKC3awIOQRwJz+cHH8Stp8bUjBZ214=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-hg5Rl6Gjdqo475XTlrEtpuzieBT0J6ie+uGajE1MeLA=";
    };
  };
  priority = 10;
})
