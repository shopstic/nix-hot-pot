{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.1.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-xzQRtCwpksRA1XB2ILE3Gdc3r4ftT63M1WBmi6yXZzw=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-l41Axc0ZXdzQYEyueJWI8yHzlDjxPTuBgIdx/ZFpqr4=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-V9zOVX/LoE8ElAW/6uxzGk6h5TQEt62YwG0iTMk4ahc=";
    };
  };
  priority = 10;
})
