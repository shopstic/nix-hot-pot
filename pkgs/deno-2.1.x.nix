{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.1.9";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-zcUmeCQbLKtWnZd7PeXnQJ2dWA+RLKQNxuTiRknyz9Q=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-GQKC3F61WrwAwfTgqu/sAQzXDWHpOUMmjUO+6evXQe4=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-ncj0u1nvIxdeXsDNo/oOaTYoOd76nMgIzc1e9mvNrI4=";
    };
  };
  priority = 10;
})
