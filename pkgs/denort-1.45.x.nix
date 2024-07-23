{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.45.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-eBSexrkGxL3PGFKEcfmuOiI/F7Z4NvAjiqaBC9E974c=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-sO9u6FUqJttwKGClPuyVJFdkem+zsCKm47Zmu+eUrgQ=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-5gF53lMMI5Y38Iz5va1mQX29d/7y7pRvxRPXIAzsaYw=";
    };
  };
  priority = 10;
})
