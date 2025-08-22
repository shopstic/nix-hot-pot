{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.4.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-UvGjRe5d9qBy+6CLLHLVT9lJI/iJastFxWkkTSsuweI=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-Y6cwsyTl2H7c/Y2CmErdmbZR2Uw/hVTdgCLlfg5d9zM=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-GB8mAlcT8IyXj/vs7jb0O/cUCB+Ntk4zms3gucPlsZg=";
    };
  };
  priority = 10;
})
