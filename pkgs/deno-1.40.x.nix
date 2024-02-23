{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.40.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-g0ZLBdMM1LoUNGNCsYmdXR/t7+DffcHQAyeEuy7FXvg=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-ilddIOxZoBSZcPusoixjej5Xlzke/6eudlbDOgKHfE4=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-ftXkDtDtKYpOU/MZPc6zg1EKPJeEd//Sy4zgvKjrffU=";
    };
  };
  priority = 10;
})
