{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-PIygsH/3x7ALnZfJyYptwuPWdLJn1nC9SrJGJCiVOGs=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-WkAR+QFzIuzmX7MdKZ7fduyObxC8mw5joIIu6lk44OY=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-bsNPUOwZW7sdSFzanB4TYgchx2AV+qIIzOFvm5K6ntQ=";
    };
  };
  priority = 10;
})
