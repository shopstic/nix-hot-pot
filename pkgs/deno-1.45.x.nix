{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-G8Y2EUBcCEu+wUToqdTEHJeEn3wYBIHK8F9ekTVoink=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-tpF8FBCcahlkW0kR1q1xJlJ8gOCeVg5iouA6qtO4QRo=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-IUia4rcCbl8mgVak3Rm/iFOi2RUBD8Pe3l4dCiQvxHA=";
    };
  };
  priority = 10;
})
