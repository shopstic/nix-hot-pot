{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.42.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-2+8cnfyZICBDG30GL9nd41y8QdNAGFJZceta+Qh0gqE=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-R+IFMEUtXZkFrfvvwMylxSOqH1huABUXLNaZof1Sizw=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-76FxUreUujrA4co2lyLCKwwUzBELWzbfQHNj5JEcgLk=";
    };
  };
  priority = 10;
})
