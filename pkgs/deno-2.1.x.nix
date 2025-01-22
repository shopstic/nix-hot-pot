{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.1.7";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-n6JVrJ0HOkX/ZITTlUJyAiJJPLpcPIEfBahZSIvuIOc=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-1wA1SwlbLKAcd2PpAN/J7zneOCB3pqbOcqpBZR9TZZU=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-srhIDKm9SeYE5QUC8n9uUhEP8ujawV8flFrpQAcriCA=";
    };
  };
  priority = 10;
})
