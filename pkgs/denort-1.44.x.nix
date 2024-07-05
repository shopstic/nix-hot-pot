{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.44.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-/QuwlpVN0uxOoOshOy6/Ow5XXzxtysQI0jp5SnA6hnE=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-pFXdXl/xxl6bnr+PmFkfj0JRctvCqkRCRYAxpfSrmmw=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-VRMjo8sqdISK/ggLQXieszLRXjHt28+tJGF3X8gYgV4=";
    };
  };
  priority = 10;
})
