{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-srGJmk+uijWRUn7ay+v2l6Qd0d7TX3j06BjF3maqdIw=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-94yzCFPvIVxhlCDxJrEihaihI+pa9GqBEgAlqw1/3UA=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-JcXVTyyUtY16cP2f6gF7ROqcAzNnIJat4EXP5oQn1PI=";
    };
  };
  priority = 10;
})
