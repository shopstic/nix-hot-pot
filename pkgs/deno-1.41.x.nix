{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.41.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-0tzBFnTJOn22QdyR9r0jDLAQ4vcGgN51aQ1K7aqmEAU=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-9StBznLvyR6rpHDASVhTdzvOn2ci84yzUXWR3oFkTDI=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-TL2AQzoL7OtoBJyTWjPUW0vtbw9y/qJyjT5eJdltFwU=";
    };
  };
  priority = 10;
})
