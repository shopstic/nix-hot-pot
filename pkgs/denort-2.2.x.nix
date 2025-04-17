{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.2.10";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-JCIMfo++AyPXu2dv336cy5kyTKpm0MIxYVeXjQJMW7I=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-lnX7k8GbkrSzCUcP7XKZVLaI1nyVLZWN5Gpmp2tUVOM=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-9baHfvKuni/iVk81KZNNEfqcfL0Win0YqvN7YZXWOW4=";
    };
  };
  priority = 10;
})
