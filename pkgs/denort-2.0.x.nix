{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.0.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-niTq6yme+z33LnaPx/3QsQ7Hwa/Q7cdymVaXiCsj/uw=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-c/h/c2cRGT/PKz1St93mPGodHD/Z3LDiDBpzdhgdzF4=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-BXmgYZmdqicz1iPut30u8SS31sIzOmhsdrK4ElHCPbc=";
    };
  };
  priority = 10;
})
