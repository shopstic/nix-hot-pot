{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.43.6";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-1hwLRIlVxkrKQUluHycItCNx2o+wpOIb1JIxS3XEONk=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-xejPQty0eIoqyjktSWUpU6sL/wtdL/mG6xIOA1n5NIk=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-hHWCmtLCCFKIT+nxCfAxbrWwmqQ3HCShHZsd2XOSdUc=";
    };
  };
  priority = 10;
})
