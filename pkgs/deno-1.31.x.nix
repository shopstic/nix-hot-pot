{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.31.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-yHV6oX0sHwlEREHZQL+gso5lBz6NYl+K0fYuN/uR9+Y=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-C2H6UKaA+DPYqOK0tFPR8szY4mFTlZXxL+dItziVKyQ=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-qj/fDAY3I00YCuXgXrMIrwCqsUO8HbBLzKtJ0cAxsKE=";
    };
  };
  priority = 10;
})
