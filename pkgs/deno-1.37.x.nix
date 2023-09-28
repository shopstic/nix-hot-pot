{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.37.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-VTNjeCDguNbyFlK/WETpDL/tT7nVfzXFsadThKMcvKc=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-aH79eRIFQgT+xISFgVIC/N8Q2e5nMpsHiVzO/yQ7KXU=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-wEEYbjDSzVXTtu0PyLMtym1MLZWJlwMbFaijwjO1SIk=";
    };
  };
  priority = 10;
})
