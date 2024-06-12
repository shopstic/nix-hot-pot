{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.44.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-j2b4rGdNzSqxDObPSa/uO1oXZsWHzGHcW6xH2iACPFc=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-fzPsLDBm54GAd5crqnWKdAdyO3QdUMwOGIPIs0hHfcw=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-I0FWDl7buuY8vkMkMumEcuigIMmPaKg8V6+V3opfyNQ=";
    };
  };
  priority = 10;
})
