{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "1.46.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-bCF32h3TjzoZ80tlRKI4g/XNREhWHjcN2S5TxgV7Gxw=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-9jTTYkg+xR4AP6j6RXUTiD2qGfgvwHWwX0j1WCSKrHQ=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-H0UBINCiasljRg7jqoSJ9c0wcY6w3sgAFF0fAEyuaC8=";
    };
  };
  priority = 10;
})
