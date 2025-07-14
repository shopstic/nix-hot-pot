{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.4.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-9mZgXV2Nn864O9gCLIAfYhseqsm5+cN4ACYLJylmDHA=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-Hemfm5mbeWQh82UWIBawAw+v5zDC98QJ1IjpAJsBL8Q=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-9rq1tGGZywAvINKkj6kUqbOADJwTwNse0aXioBadcpE=";
    };
  };
  priority = 10;
})
