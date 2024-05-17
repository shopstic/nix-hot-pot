{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.43.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-+fuH30pEYxs6kwwfpJMJb3n9wcXwDwRXQvON+PWKkXE=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-S+fRXCTnxoXRcyrCwrHmGKxaCim1TmoE++OuG73prY0=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-uZaCBTEa/c9OghHUs50A/aVnL+qrZgpiR6jnNGa4/Io=";
    };
  };
  priority = 10;
})
