{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.0.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-WQ4B0sT3qTVl4/Moj0FcFg5LDZIBPbnmcfUxwrmFyYY=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-03fJO1fbunRBmdKrQYt9VdNhYetGvf/xwrn+EneoARI=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-a4jQ2fp7QHEt36qNrDECEfyfoqs2Qns5xxIkY9g+Oi0=";
    };
  };
  priority = 10;
})
