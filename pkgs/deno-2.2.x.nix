{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.2.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-pTNhvPmEMeDxlAlXVAnWm4X/nccbREo2eL/9xeJ+d0s=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-BJ4FOb3fZkCPlRlNsCG76HBdoNT6fiksG1dWkLB5mT0=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-o5qiM5XCRqSAGbJdl1RO3APzzRddcrvkLTVO/oT+N30=";
    };
  };
  priority = 10;
})
