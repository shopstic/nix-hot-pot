{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-crbQjyOvpvASiAN1shlDutjN+Az9Q6VFVZ+ZX5OXr9k=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-oM2+WrMhNDqmDJrZ+H6JJlzJAg6sR+SirZTNmWgi23g=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-RNZ09vSUOLqtHVTeas5aD6t+XJs1/tLXs+pEdToZjIU=";
    };
  };
  priority = 10;
})
