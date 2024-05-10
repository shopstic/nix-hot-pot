{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.43.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-H5z2CDLR+tLIoIF1geRyObPuC6+4RecZZavpjS+2ZpE=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-Jpq4wqbxPMfxHn4YtWocvMAChYkiRuNYWp7d0nMTZ3s=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-AUQw/wOBUfWfNSVqFYbHxA8h8iMjKBYGT2ADGuNzwes=";
    };
  };
  priority = 10;
})
