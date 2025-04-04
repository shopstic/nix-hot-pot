{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.2.7";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-/LU4dYW24vvqo55ipO+U/KZlUoCdTg9UbpbSQFPwEtQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-MzatZbpADB4rYAjM7FEcZPZy7hJfsnfpFwUt1acZf74=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-89c01FKoYPlPd97dCVO5wXtAjFVWvMA6f3BNnIbnpLw=";
    };
  };
  priority = 10;
})
