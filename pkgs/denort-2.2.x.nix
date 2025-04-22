{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.2.11";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-PdRlaEwH4fK8KFZNON+8oNN/Dzrd+oiIkJ8xRH+aOOA=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-CpoWbcN6wnpsiOZZnfJDASVJgze8iZ6HE/1bUE9niZg=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-bU4ewCNK3iNZ9Ll6UZaNcyd3csK+juR81TfF4MSaXVg=";
    };
  };
  priority = 10;
})
