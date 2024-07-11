{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-m6StZPQK4WSxry0mDiOm+Ezj3HKxOWxMoPeYQV81ptk=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-HoPnEFbEpYtRod4poBq+QrH1EcSlAwuz9WIqZRhMzno=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-p5Trj87Mk6+ZP/aLoKVMR9vJHPoX6VZR6Qk8d+pjD+o=";
    };
  };
  priority = 10;
})
