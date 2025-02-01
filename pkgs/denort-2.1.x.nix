{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.1.9";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-wklWIeNNtJ5YIo7NJ09VuJ2XgBhPGkOoKK/D9nVGKdI=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-Gy6hcrBWHxGaf0YlORAXxxHnXpV1MhXZZ4UXV0jCEOM=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-ju9L8qPJRvpDVPNjUIimXUof/Umsj9CrBHyjCMs7EHc=";
    };
  };
  priority = 10;
})
