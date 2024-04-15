{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.42.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-MkhdrQZubuR70cnCdH4cW1SoaIOfpqp0oqo4K8BU0T0=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-Yn6FaZ5LUKSr7K/bY2IAorOIlIPTBGTguqbEhao5yS8=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-9a4qZ2G1URFpIZ6y5GpPitAV+0BX8z9Jtcsj0LbZKT0=";
    };
  };
  priority = 10;
})
