{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.44.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-xy8Am38gR+yhRphfFxLRb2PjaiUFC58oYfJV06k6ppI=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-avQvB2kVh1pTM6RjsB5B4ORfHngFl81y4lG6kGVEN/Y=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-CohDc7C7orilIHkaHzB8CHd7BIinwjWgHZFsu1WOHz4=";
    };
  };
  priority = 10;
})
