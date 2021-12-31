{ autoPatchelfHook, fetchzip, stdenv }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv;
  version = "1.17.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-mdqfzylm5TbkMWE0aNhG86gHcr+6H7kuSwb4akz5oM4=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-P05k/FZ0gviL3q0F2JCugZaX1Zuj7ztU6xGG3qdaGdk=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-7kx+y7txvuriaPmyTjtKBGNtjfBIdBvlxoUQPM2i+lw=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-CZ5VYI/MYQ8NRKNhpjbizpOpZTdFcTkGl7my4gyk7gE=";
    };
  };
  priority = 10;
})
