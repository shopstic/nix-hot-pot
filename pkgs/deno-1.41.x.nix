{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.41.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-s3jf6CWf41UonmasxTCY/vVatfA7c7kHQ4SodGHn7xM=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-X0y5hVqzyr8qpDZoN6rqoDObcariJLfWafBNR8EPTvQ=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-63OZlldj4GWybtret6FxZ9ABCeh5tEp7f6NIvCeugTU=";
    };
  };
  priority = 10;
})
