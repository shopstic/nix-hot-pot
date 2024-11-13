{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.0.6";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-DZAXNk1UpBc7cXQF3kQEU4weflhk0OZ2cB+4/hLGKrU=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-r+hYVCGwYewiOZKaXCdGhXdoJt9bI+3cppVi3NAaTVA=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-L2ZFAzAe8wQwNRUqRHdBeJncwdgw2XxUOUhJEHW0f3k=";
    };
  };
  priority = 10;
})
