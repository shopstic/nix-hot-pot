{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.2.8";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-O+zNB75P+HSNE1M8EIhjOQ7OS9nytFjA5wHW7Vc6jvc=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-Zi3fzenaeHGFXccSruLRvaWDy5Tvu4lkNacLSrLkUvk=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-62R8G04e/2/ZLgHsAH5rR388bSbPG1GJENSw+LAjVA0=";
    };
  };
  priority = 10;
})
