{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.5.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-pxzkP/3VOpVd63hPXICdJFCJHGpEqfKPwCGo7H0/Xd0=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-9rXXTwpa5yK8Nicx7bJ9djq1iii0o9GVyWsoujyWr24=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-8AXji7ubLle7wEoFljWKjMQd4S5I+glLcLnhGp+h/Fo=";
    };
  };
  priority = 10;
})
