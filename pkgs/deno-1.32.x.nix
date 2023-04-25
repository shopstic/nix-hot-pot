{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.32.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-2yw0IZMhLxlw2Fhs3C+NShShCHuDsN46Qopc7SnVm68=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-tXJ3sgcUjzvTRWGOcQTnwaVPZkVJlz8YNCdWgvkemn8=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-Za+txViO8EG+sIFpDidH10JhhqVf6Ffi5z5Ic/wQX/s=";
    };
  };
  priority = 10;
})
