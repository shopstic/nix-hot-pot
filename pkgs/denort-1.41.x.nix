{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.41.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-hvjRZdiyUyIPGFGUu6ufhUJZsX+GiJT8G+5MKLU5dUo=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-bUOli5K/fZ6obflEBo6R2iHNTyiwaUTs91V2mmRcV1M=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-t/KmiFa8D4vA5jiDd8HaB9pkJJaCCCLDoDV67/CdLtk=";
    };
  };
  priority = 10;
})
