{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "1.46.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-vnDzegjO7XFqBj3dZ1T4TZfuFr3Ur2f4/2zlFUQUwSI=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-NSFXWA8KCTCDYqDYnOWOtygHJUWtEukrtQITNB28Vyw=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-BOWExLWmDHOZBESZCVV5W0M/hF6w3POVL2ZmW7Y8hzo=";
    };
  };
  priority = 10;
})
