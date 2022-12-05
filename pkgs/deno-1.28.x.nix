{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.28.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-+HqxUNFxi6yyDJMcX9i2vrYGCXK5qUE/j9KfuMWsqP4=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-6yVghLGtidLVMqf3aPTDK5cwK3i/LDhWwDS+PTqccYA=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-SNSw9qHuz8e6P0cyyzt8/sfRngl87FXxj8QFqWj3W8U=";
    };
  };
  priority = 10;
})
