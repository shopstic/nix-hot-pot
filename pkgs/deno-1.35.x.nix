{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.35.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-z5qfJOigo/vVmOHWwc1JKb4UKYa03itC8Qy8cmr5rZM=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-ZLsqY9R87/VnOA01DSbSrvuiHrHXhVsq+Zin5fK9FII=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-Xt4sQA9ABpEy6SB8NDgC5E3rJf0xoIO5+5MzWTo4rAc=";
    };
  };
  priority = 10;
})
