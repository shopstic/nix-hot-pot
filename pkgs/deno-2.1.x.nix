{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.1.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-n+NAT+0CWQwgZcnJ7dFqiuti+Ayp5nIj2VlsFd14N9Q=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-NAOg7/D9zuW8vhB1lASyYQBA1VWIRlu+9KzM2sJx/AU=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-WbrUH/agNftPjjBFaFZpyTMULHVS9NMkKnkiqk/hhpA=";
    };
  };
  priority = 10;
})
