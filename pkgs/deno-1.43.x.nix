{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.43.6";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-gP/0NQT8FYgmlfG2AOjfF0/Khut6EPGwcnodmbR+wko=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-Oiw1RDEFsP/qK/HVon3niPhh3lw+jbOyov6F+Pab3lc=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-p3gen103+TShQ4Np6BXLo5dULkAEcEuKDSx9f5wRfcI=";
    };
  };
  priority = 10;
})
