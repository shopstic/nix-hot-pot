{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.1.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-OJ6RA4nk5AaDrpykWbA0AQEnMX9LSL14iD1wb0VurtU=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-mOHxicvMn/EisISjjlz9eV5dU+WjiJV3E/+UVBOkytw=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-oAe38pGusyflFsWBP8VnoTcn+6FMlvGhlXShZmPL1rk=";
    };
  };
  priority = 10;
})
