{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.0.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-tkuOgKZ6XoFJwSo/75yDnc771M01vXxaXzYaO+cnZbA=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-gZ0nPtMMd9GJQXH2BZ3r/s1FvhI9Aw6I2ec8lKpE/U0=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-CY0A8HABkXkjbb8ZbSL5sZT1NZjQJq4m+RjbSPBl0eI=";
    };
  };
  priority = 10;
})
