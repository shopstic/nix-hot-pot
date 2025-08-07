{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.4.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-EPtx9C1HIGkLfmHnwuxEfMvD+gbzVCLTarOLNf111Nk=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-ZUYJRKgOFs5T4Zm2GVQf6gfN5an8uPNSFUPA4WPkn2k=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-QnKTvcvUzh1Bn5vpcgbhnYtSTKCW7Sw5w56hGd0FvkQ=";
    };
  };
  priority = 10;
})
