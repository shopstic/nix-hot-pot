{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.42.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-Poz+Vb9w3w6cSs9QQAMGI6kunxrCxvbWxmMA1amglAQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-CayHPLn9l6dO5ZlIUxTjYabFUAhohChK5pQ0EakaCZc=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-C68Qyw1Ql3qr4OD2RB9ZwfWujNIn7bjs33p9jAvPsaQ=";
    };
  };
  priority = 10;
})
