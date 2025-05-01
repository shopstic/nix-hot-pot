{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.3.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-abOOrvDOz+Le+sKGoo3R+UWxqJz7ibXL3yRMbYMunBI=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-E3UxWQm8nGWBomxfwDeGa+/fJZZo7nIWQN8f0ZoMlQQ=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-71nN3T9WSULBkrifKSoSaeXg+jjoF/b2gyeN6lsJb5U=";
    };
  };
  priority = 10;
})
