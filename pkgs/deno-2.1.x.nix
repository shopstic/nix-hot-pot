{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.1.10";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-D0hoJRl+llbNVClKnq98bQMvQ0Epdw6C39oIp0bXhWQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-ce3/Mx4b1E0YqF01wb6sxf4LQBLHNuW7yLLoP4BUpng=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-oNy92TySm5Cazw/RuJQ15osWGYeDOqhJaU4AB4kF6s0=";
    };
  };
  priority = 10;
})
