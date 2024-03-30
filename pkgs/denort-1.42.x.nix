{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.42.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-I/c3RQoxP8h0RP9cPshDoePK26sk1xOSoLis7Ik7pzg=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-2U/lTXy6JZzQZuJycI6UBz7J6U/H99qRRP0wioh0Rwo=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-b3cONL5PHHgtjG129Z6I9LzQ1Il9/o4JCij4upjfOwc=";
    };
  };
  priority = 10;
})
