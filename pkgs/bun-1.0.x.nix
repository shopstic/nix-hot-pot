{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./bun.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.0.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64-baseline.zip";
      hash = "sha256-Q1Kf1KTGm30ESAaUk7d/B3BG4WKHfMsgjWWtf5BiDng=";
    };
    aarch64-darwin = {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
      hash = "sha256-LYNB+grgy5u19RSqtHcqNRgeP6lIK8RaZNS0ofMRAPc=";
    };
    aarch64-linux = {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
      hash = "sha256-bVKDU/8A/OU8x6CwS1BNpJi3PH5WpwZPNlCC5OjxOws=";
    };
  };
  priority = 10;
})
