{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.43.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-Ee5B8Uz/7jkiLP9wKCoVXdhggi4Px4ggYWubDjbYmwA=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-BtHzLHgwJ/yNOILJbardmQ6DJ+8EKWKelIc3ZHbze1k=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-okjXbxfmPXgs9DxOaE328jaINfVgLXrYBl7KBVKu3/w=";
    };
  };
  priority = 10;
})
