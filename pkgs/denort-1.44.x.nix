{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.44.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-nst4IV3WjSCD9yV3Tl4tKvePTtwblrjyDTppfl0P2SE=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-xSVTUnR6q0VG6bADYZYokYH8TLr4OrvSpwOXMDo70GY=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-BMPMsM/zVTgJ4SqRxWd0QZHMteesILKmtZtYCd7YunI=";
    };
  };
  priority = 10;
})
